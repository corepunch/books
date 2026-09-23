#!/usr/bin/env python3
"""Stage only runtime resources, preserving the engine's filesystem conventions."""
import argparse
from pathlib import Path
import plistlib
import re
import shutil


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('root', 'target', 'binary', 'icons'):
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--book', required=True)
    parser.add_argument('--bundle-id', required=True)
    parser.add_argument('--sdk', choices=('iphoneos', 'iphonesimulator'), required=True)
    parser.add_argument('--sdk-version', required=True)
    parser.add_argument('--minimum', required=True)
    args = parser.parse_args()
    root, target, adventure = args.root.resolve(), args.target.resolve(), args.book
    if target.suffix != '.app' or target == root or target in root.parents:
        raise SystemExit('Target must be a separate .app bundle')
    if not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', adventure):
        raise SystemExit('BOOK must be a lowercase adventure identifier')
    if adventure != 'three-stars' or not (root / 'books/three-stars/rooms/attic.blks').is_file():
        raise SystemExit('Missing C adventure assets: ' + adventure)
    target.mkdir(parents=True, exist_ok=True)
    # Clear only generated resources/signatures; never ship stale art or signing.
    for directory in ('fonts', 'books', 'libs', 'assets', '_CodeSignature'):
        if (target / directory).exists():
            shutil.rmtree(target / directory)
    (target / 'embedded.mobileprovision').unlink(missing_ok=True)
    (target / 'Lua-LICENSE.txt').unlink(missing_ok=True)

    def stage(directory, extensions):
        source = root / directory
        for file in source.rglob('*'):
            if file.is_file() and file.suffix.lower() in extensions:
                destination = target / file.relative_to(root)
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(file, destination)

    stage('fonts', {'.ttf', '.txt'})
    back_button = root / 'assets/back-button.png'
    if not back_button.is_file():
        raise SystemExit('Missing runtime asset: ' + str(back_button))
    destination = target / back_button.relative_to(root)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(back_button, destination)
    stage('books/' + adventure + '/rooms', {'.jpg', '.jpeg', '.blks', '.blk'})
    shutil.copy2(args.binary, target / 'Book')
    for icon in args.icons.iterdir():
        if icon.suffix in ('.car', '.png'):
            shutil.copy2(icon, target / icon.name)
    info = plistlib.loads((root / 'platform/ipad/Info.plist').read_bytes())
    info.update(plistlib.loads((args.icons / 'partial.plist').read_bytes()))
    info.update({
        'BookAdventure': adventure,
        'CFBundleIdentifier': args.bundle_id,
        'CFBundleExecutable': 'Book',
        'CFBundleName': 'Book',
        'UIDeviceFamily': [2],
        'MinimumOSVersion': args.minimum,
        'CFBundleSupportedPlatforms': ['iPhoneOS' if args.sdk == 'iphoneos' else 'iPhoneSimulator'],
        'DTPlatformName': args.sdk,
        'DTPlatformVersion': args.sdk_version,
        'DTSDKName': args.sdk + args.sdk_version,
    })
    (target / 'Info.plist').write_bytes(plistlib.dumps(info))
    (target / 'PkgInfo').write_bytes(b'APPL????')
    print('Packaged ' + str(target))


if __name__ == '__main__':
    main()
