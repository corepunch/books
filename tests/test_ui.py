"""Optional Metal regression check; requires access to the macOS window server."""
import json
import math
from pathlib import Path
import subprocess
import sys
import tempfile

binary, root = map(lambda value: str(Path(value).resolve()), sys.argv[1:3])
args = [binary, '--root', root, '--book', 'three-stars']
page = json.loads(subprocess.check_output(args + ['--check'], text=True))
origin = page['hotspots'][0]


def capture(directory, milliseconds=None):
    path = Path(directory) / f'page-{milliseconds}.ppm'
    mode = ['--smoke'] if milliseconds is None else ['--smoke-transition', str(milliseconds)]
    subprocess.run(args + mode + ['--screenshot', str(path)], check=True)
    with path.open('rb') as image:
        assert image.readline() == b'P6\n'
        width, height = map(int, image.readline().split())
        assert image.readline() == b'255\n'
        pixels = image.read()
    assert len(pixels) == width * height * 3
    return width, height, pixels


with tempfile.TemporaryDirectory(prefix='book-ui-') as directory:
    width, height, before = capture(directory)
    scale = width / 1100
    assert height / 800 == scale
    cx, cy = origin['x'], origin['y']
    end_radius = math.hypot(max(cx, 1100 - cx), max(cy, 800 - cy)) + 1
    for milliseconds in (0, 100, 275):
        frame_width, frame_height, frame = capture(directory, milliseconds)
        assert (frame_width, frame_height) == (width, height)
        progress = milliseconds / 550
        eased = progress * progress * (3 - 2 * progress)
        radius = 24 + (end_radius - 24) * eased
        unchanged = changed = 0
        for y in range(height):
            for x in range(width):
                offset = (y * width + x) * 3
                different = frame[offset:offset + 3] != before[offset:offset + 3]
                # Allow a pixel at the rasterized reveal boundary.
                if math.hypot((x + .5) / scale - cx, (y + .5) / scale - cy) > radius + 1:
                    assert not different, f'Outgoing page changed outside reveal at {milliseconds} ms: {(x, y)}'
                    unchanged += 1
                changed += different
        assert unchanged > 0 and changed > 0
    _, _, after = capture(directory, 850)
    assert after != before

print('Book: outgoing text, circles and artwork remain pixel-identical outside the reveal')
