#!/usr/bin/env python3
"""Render book artwork offline with Scener; filenames come from camera names."""
import argparse
from pathlib import Path
import subprocess
import tempfile
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--book', default='three-stars')
p.add_argument('--scene', default='attic')
p.add_argument('--scener', default=str(Path.home() / '.local/bin/scener'))
p.add_argument('--width', type=int, default=1920)
p.add_argument('--height', type=int, default=1440)
a = p.parse_args()
for name in (a.book, a.scene):
    if not name or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in name):
        p.error('book and scene must be simple names')
rooms = root / 'books' / a.book / 'rooms'
scene = rooms / f'{a.scene}.blks'
names = [n.attrib['name'] for n in ET.parse(scene).getroot().findall('camera')]
if not names or len(names) != len(set(names)):
    p.error('scene requires unique named cameras')
for name in names:
    if not name or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-' for c in name):
        p.error(f'invalid camera/asset name: {name}')
if a.width <= 0 or a.height <= 0:
    p.error('render dimensions must be positive')
# A failed render never replaces existing artwork. Scener uses scene-relative prefabs.
with tempfile.TemporaryDirectory(prefix='.render-', dir=rooms) as tmp:
    subprocess.run([a.scener, '--render', scene.name, '--size', f'{a.width}x{a.height}',
                    '--format', 'jpg', '--output-dir', tmp], cwd=rooms, check=True)
    outputs = [Path(tmp) / f'{name}.jpg' for name in names]
    if not all(path.is_file() and path.stat().st_size for path in outputs):
        raise SystemExit('Scener did not produce every camera image; existing art retained')
    for path in outputs:
        path.replace(rooms / path.name)
print(f'{len(names)} JPEGs written to {rooms}')
