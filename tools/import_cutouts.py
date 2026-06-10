#!/usr/bin/env python3
"""Import design cutouts into lgdz/Assets.xcassets as @2x imagesets.

Design base is 780x1688 == @2x of 390x844, so cutouts are registered at 2x
scale. Usage:

    python3 tools/import_cutouts.py "<src_png>=<asset_name>" ["<src>=<name>" ...]

Source paths are relative to 项目设计图/设计图细节切图 unless absolute.
Only files under the allowed cutout root may be imported (design originals are
forbidden as runtime assets).
"""
import json
import os
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CUTOUT_ROOT = os.path.join(ROOT, "项目设计图", "设计图细节切图")
ASSETS = os.path.join(ROOT, "lgdz", "Assets.xcassets")
FORBIDDEN = os.path.join(ROOT, "项目设计图", "设计图原稿")


def resolve(src: str) -> str:
    p = src if os.path.isabs(src) else os.path.join(CUTOUT_ROOT, src)
    p = os.path.abspath(p)
    if p.startswith(os.path.abspath(FORBIDDEN)):
        raise SystemExit(f"REFUSED: design original is not a runtime asset: {src}")
    if not os.path.isfile(p):
        raise SystemExit(f"missing source: {p}")
    return p


def import_one(src: str, name: str):
    p = resolve(src)
    imgset = os.path.join(ASSETS, f"{name}.imageset")
    os.makedirs(imgset, exist_ok=True)
    # clear stale files
    for f in os.listdir(imgset):
        os.remove(os.path.join(imgset, f))
    fname = f"{name}@2x.png"
    shutil.copyfile(p, os.path.join(imgset, fname))
    contents = {
        "images": [
            {"idiom": "universal", "scale": "1x"},
            {"idiom": "universal", "filename": fname, "scale": "2x"},
            {"idiom": "universal", "scale": "3x"},
        ],
        "info": {"author": "xcode", "version": 1},
    }
    with open(os.path.join(imgset, "Contents.json"), "w") as fh:
        json.dump(contents, fh, indent=2)
    print(f"imported {name}  <- {os.path.relpath(p, ROOT)}")


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    for arg in sys.argv[1:]:
        if "=" not in arg:
            raise SystemExit(f"bad arg (need src=name): {arg}")
        src, name = arg.split("=", 1)
        import_one(src.strip(), name.strip())


if __name__ == "__main__":
    main()
