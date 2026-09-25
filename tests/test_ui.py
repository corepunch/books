"""Optional Metal regression check; requires access to the macOS window server."""
import json
import math
from pathlib import Path
import subprocess
import sys
import tempfile

binary, root = map(lambda value: str(Path(value).resolve()), sys.argv[1:3])
book = sys.argv[3] if len(sys.argv) > 3 else 'lighthouse'
args = [binary, '--root', root, '--book', book]
page = json.loads(subprocess.check_output(args + ['--check'], text=True))
# The smoke transition presses the first circle, or the button when the page has none.
circles = [c for c in page['controls'] if c['circle']]
control = circles[0] if circles else page['controls'][0]
route = subprocess.check_output(args + ['--headless'], input=f":choose {control['choice']}\n", text=True)
after_page = json.loads(route.splitlines()[-1])
button = next(c for c in after_page['controls'] if not c['circle'])


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
    cx, cy = control['x'] + control['width'] / 2, control['y'] + control['height'] / 2
    start_radius = 24 if control['circle'] else 0
    end_radius = math.hypot(max(cx, 1100 - cx), max(cy, 800 - cy)) + 1
    # A new picture is revealed in a growing circle; the same picture crossfades its text.
    reveal = after_page['image'] != page['image']
    for milliseconds in (0, 100, 275):
        frame_width, frame_height, frame = capture(directory, milliseconds)
        assert (frame_width, frame_height) == (width, height)
        if not reveal:
            assert milliseconds == 0 or frame != before, f'crossfade did not start by {milliseconds} ms'
            continue
        progress = milliseconds / 550
        eased = progress * progress * (3 - 2 * progress)
        radius = start_radius + (end_radius - start_radius) * eased
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
    # Inspect the button interior, excluding its border. A rendered label must
    # contain cream text pixels; headless choice existence alone cannot prove this.
    cream_pixels = 0
    for y in range(int((button['y'] + 8) * scale), int((button['y'] + button['height'] - 8) * scale)):
        for x in range(int((button['x'] + 8) * scale), int((button['x'] + button['width'] - 8) * scale)):
            offset = (y * width + x) * 3
            rgb = after[offset:offset + 3]
            cream_pixels += all(abs(actual - expected) <= 6 for actual, expected in zip(rgb, (244, 230, 202)))
    assert cream_pixels > 50, 'The button label is missing from the rendered next page'

print('Book: the page transition keeps the outgoing page outside the reveal and the next page renders its button')
