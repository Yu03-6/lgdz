import AVFoundation
import UIKit

/// Screen 20 — Video chat. Local camera preview in PIP; remote peer shows
/// grayscale avatar + loading spinner. Mic/speaker toggle via cutout buttons.
/// After 10 s without connection, pops to chat and shows failure popup (§6: no RTC).
final class VideoChatViewController: UIViewController {

    private let peerName: String
    private let peerAvatar: String

    private let remoteContainer = UIView()
    private let remoteAvatar = UIImageView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let pipContainer = UIView()
    private let timerLabel = UILabel()

    private var muteButton: UIButton!
    private var speakerButton: UIButton!

    private var seconds = 0
    private var callTimer: Timer?
    private var connectTimeoutTimer: Timer?
    private var didTriggerTimeout = false

    private var isMicOn = true
    private var isSpeakerOn = true

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    init(peerName: String, peerAvatar: String) {
        self.peerName = peerName
        self.peerAvatar = peerAvatar
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        hideSystemNavBar()
        build()
        startCallTimer()
        scheduleConnectTimeout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestCameraAndStartPreview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            teardownSession()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = pipContainer.bounds
    }

    deinit {
        callTimer?.invalidate()
        connectTimeoutTimer?.invalidate()
    }

    // MARK: - UI

    private func build() {
        remoteContainer.backgroundColor = UIColor(white: 0.12, alpha: 1)
        remoteContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(remoteContainer)

        remoteAvatar.image = UIImage(named: peerAvatar)?.grayscale()
        remoteAvatar.contentMode = .scaleAspectFill
        remoteAvatar.clipsToBounds = true
        remoteAvatar.layer.cornerRadius = 120.dp
        remoteAvatar.translatesAutoresizingMaskIntoConstraints = false
        remoteContainer.addSubview(remoteAvatar)

        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = false
        loadingIndicator.startAnimating()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        remoteContainer.addSubview(loadingIndicator)

        pipContainer.backgroundColor = UIColor(white: 0.2, alpha: 1)
        pipContainer.clipsToBounds = true
        pipContainer.layer.cornerRadius = 24.dp
        pipContainer.layer.borderWidth = 2
        pipContainer.layer.borderColor = UIColor.white.cgColor
        pipContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pipContainer)

        let back = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: DesignMetrics.font(44), weight: .semibold)
        back.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        back.tintColor = .white
        back.addTarget(self, action: #selector(endCall), for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        timerLabel.text = formatted(seconds)
        timerLabel.font = DesignTokens.Font.bold(44)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)

        muteButton = cutoutButton(imageName: "video_mic_on")
        muteButton.addTarget(self, action: #selector(toggleMic), for: .touchUpInside)

        let end = cutoutButton(imageName: "video_end_call")
        end.addTarget(self, action: #selector(endCall), for: .touchUpInside)

        speakerButton = cutoutButton(imageName: "video_speaker_on")
        speakerButton.addTarget(self, action: #selector(toggleSpeaker), for: .touchUpInside)

        let controls = UIStackView(arrangedSubviews: [muteButton, end, speakerButton])
        controls.axis = .horizontal
        controls.distribution = .equalSpacing
        controls.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controls)

        NSLayoutConstraint.activate([
            remoteContainer.topAnchor.constraint(equalTo: view.topAnchor),
            remoteContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            remoteContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            remoteContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            remoteAvatar.centerXAnchor.constraint(equalTo: remoteContainer.centerXAnchor),
            remoteAvatar.centerYAnchor.constraint(equalTo: remoteContainer.centerYAnchor, constant: -40.dp),
            remoteAvatar.widthAnchor.constraint(equalToConstant: 240.dp),
            remoteAvatar.heightAnchor.constraint(equalToConstant: 240.dp),

            loadingIndicator.centerXAnchor.constraint(equalTo: remoteContainer.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: remoteAvatar.bottomAnchor, constant: 40.dp),

            pipContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.dp),
            pipContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120.dp),
            pipContainer.widthAnchor.constraint(equalToConstant: 240.dp),
            pipContainer.heightAnchor.constraint(equalToConstant: 330.dp),

            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.dp),
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.dp),

            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: controls.topAnchor, constant: -60.dp),

            controls.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70.dp),
            controls.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70.dp),
            controls.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50.dp),
        ])
    }

    private func cutoutButton(imageName: String) -> UIButton {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.translatesAutoresizingMaskIntoConstraints = false
        b.widthAnchor.constraint(equalToConstant: 140.dp).isActive = true
        b.heightAnchor.constraint(equalToConstant: 140.dp).isActive = true
        return b
    }

    private func formatted(_ s: Int) -> String {
        String(format: "%02d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
    }

    // MARK: - Timers

    private func startCallTimer() {
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.seconds += 1
            self.timerLabel.text = self.formatted(self.seconds)
        }
    }

    private func scheduleConnectTimeout() {
        connectTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.handleCallNotConnected()
        }
    }

    private func invalidateTimers() {
        callTimer?.invalidate()
        callTimer = nil
        connectTimeoutTimer?.invalidate()
        connectTimeoutTimer = nil
    }

    // MARK: - Controls

    @objc private func toggleMic() {
        isMicOn.toggle()
        let name = isMicOn ? "video_mic_on" : "video_mic_off"
        muteButton.setImage(UIImage(named: name)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    @objc private func toggleSpeaker() {
        isSpeakerOn.toggle()
        let name = isSpeakerOn ? "video_speaker_on" : "video_speaker_off"
        speakerButton.setImage(UIImage(named: name)?.withRenderingMode(.alwaysOriginal), for: .normal)
        applySpeakerRoute()
    }

    private func applySpeakerRoute() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .videoChat, options: [.allowBluetooth])
            if isSpeakerOn {
                try session.overrideOutputAudioPort(.speaker)
            } else {
                try session.overrideOutputAudioPort(.none)
            }
        } catch {
            // UI toggle still reflects user intent when audio session is unavailable.
        }
    }

    @objc private func endCall() {
        invalidateTimers()
        teardownSession()
        navigationController?.popViewController(animated: true)
    }

    private func handleCallNotConnected() {
        guard !didTriggerTimeout else { return }
        didTriggerTimeout = true
        invalidateTimers()
        teardownSession()
        guard let nav = navigationController else { return }
        nav.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard let chat = nav.topViewController else { return }
            let popup = ReminderPopupController(
                title: "Call Failed",
                bodyParts: [("Call not connected, please try again later.", false)],
                buttonTitle: "OK"
            )
            popup.present(over: chat)
        }
    }

    // MARK: - Camera

    private func requestCameraAndStartPreview() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCameraPreview()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCameraPreview()
                    }
                }
            }
        default:
            break
        }
    }

    private func setupCameraPreview() {
        guard captureSession == nil else { return }
        let session = AVCaptureSession()
        session.sessionPreset = .medium

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        session.addInput(input)

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = pipContainer.bounds
        pipContainer.layer.insertSublayer(layer, at: 0)

        captureSession = session
        previewLayer = layer

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    private func teardownSession() {
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        captureSession = nil
        previewLayer = nil
    }
}

// MARK: - Grayscale helper

private extension UIImage {
    func grayscale() -> UIImage? {
        guard let ci = CIImage(image: self) else { return self }
        guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return self }
        filter.setValue(ci, forKey: kCIInputImageKey)
        guard let output = filter.outputImage else { return self }
        let context = CIContext(options: nil)
        guard let cg = context.createCGImage(output, from: output.extent) else { return self }
        return UIImage(cgImage: cg, scale: scale, orientation: imageOrientation)
    }
}
