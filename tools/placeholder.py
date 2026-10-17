#!/usr/bin/env python3
"""Make placeholder pictures and clips for a book, so it can be played before it is drawn.

Every camera a page shows becomes rooms/<camera>.jpg: a solid colour per location, the
camera's name and its brief (the `comment` in the .blks scene), and a labelled mark on
every anchor a page puts a circle on. Every clip becomes clips/<clip>.mp4: a still with
the prose of the pages that play it, held long enough to read, with a bar that fills as
it plays. Each carried icon gets rooms/item-<id>.jpg.

A placeholder carries a marker (a JPEG comment, the movie's description) with a hash of
what it shows. Files without the marker are finished art and are never touched. A
painting in illustrations/<camera>.png is drawn in place of rooms/<camera>.jpg anyway;
a filmed clip replaces the placeholder at the same path. Placeholders nothing names any
more are deleted. `make placeholders BOOK=salt` runs this; `book assets` lists what is
still a placeholder.
"""
import argparse
import colorsys
import hashlib
import math
from pathlib import Path
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont

MARKER = 'book-placeholder'
# Raise when the drawing changes, so every placeholder is drawn again.
LAYOUT = 4
STILL_SIZE = (1248, 832)
CLIP_SIZE = (720, 480)
ICON_SIZE = (512, 512)
# The 3:2 picture fills 4:3 and 16:10 viewports by cropping its sides.
SAFE_SIDE = 0.10
SAFE_TOP = 0.17
TITLE_WIDTH = 0.58
MARKER_SCAN_BYTES = 65536
READING_WORDS_PER_SECOND = 3.2
CLIP_SECONDS = (3.0, 14.0)
CIRCLE_PAGES = {'view', 'map'}
CIRCLES = ('nav', 'explorable', 'destination', 'charview')
ACTIONS = {'trigger', 'set', 'enable', 'disable', 'give', 'remove', 'goto', 'call', 'if', 'else', 'show', 'hide',
           'script', 'holding', 'text', 'conversation', 'nav', 'explorable', 'destination', 'charview'}

root = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
p.add_argument('--book', default='salt')
p.add_argument('--root', default=str(root), help='the folder holding books/ (default: this checkout)')
p.add_argument('--stillclip', help='the clip encoder (build/tools/stillclip); without it no clips are made')
p.add_argument('--force', action='store_true', help='also replace finished art with placeholders')
a = p.parse_args()
book = Path(a.root) / 'books' / a.book
rooms, clips = book / 'rooms', book / 'clips'
fonts = root / 'fonts'


def font(size, italic=False):
    name = 'Literata-Italic-VariableFont_opsz,wght.ttf' if italic else 'Literata-VariableFont_opsz,wght.ttf'
    return ImageFont.truetype(str(fonts / name), size)


def prose(element):
    """An element's own prose, without its actions or nested pages; blank lines are paragraphs."""
    parts = [element.text or '']
    for child in element:
        if child.tag not in ACTIONS and child.tag != 'region':
            parts.append(''.join(child.itertext()))
        parts.append(child.tail or '')
    paragraphs = re.split(r'\n\s*\n', ''.join(parts))
    return '\n'.join(' '.join(paragraph.split()) for paragraph in paragraphs if paragraph.split())


def page_text(element):
    text = element.find('text')
    return prose(text) if text is not None else prose(element)


# --- The book: which cameras, anchors and clips its pages use --------------------------

title = ET.parse(book / 'title.xml').getroot()
locations = [location.get('id') for location in title.iter('location')]
cameras, clip_pages, icons = {}, {}, []
for kind in ('inventory', 'evidence', 'idea', 'emotion', 'action-icon'):
    for icon in title.iter(kind):
        icons.append((icon.get('id'), icon.get('name'), kind, prose(icon)))


def use_camera(name, location, page, kind):
    entry = cameras.setdefault(name, {'location': location, 'pages': [], 'anchors': {}, 'read': False})
    entry['pages'].append((page, kind))
    entry['read'] |= kind == 'document'


def walk(element, location, parent_camera=None):
    tag, ident = element.tag, element.get('id')
    camera = element.get('camera')
    if tag == 'conversation' and (element.get('clip') or prose(element)):
        camera = camera or parent_camera
    if camera and ident:
        kind = 'document' if element.get('read') == 'true' else tag
        use_camera(camera, location, ident, kind)
        if tag in CIRCLE_PAGES:
            for circle in element:
                if circle.tag in CIRCLES and circle.get('anchor'):
                    label = circle.get('label') + (f" (holding {circle.get('with')})" if circle.get('with') else '')
                    cameras[camera]['anchors'].setdefault(circle.get('anchor'), []).append(label)
        if element.get('clip'):
            clip_pages.setdefault(element.get('clip'), []).append(
                {'page': ident, 'kind': kind, 'location': location, 'camera': camera, 'text': page_text(element)})
    for child in element:
        if child.tag not in ('text', 'holding'):
            walk(child, location, camera if tag == 'charview' else parent_camera)


for location in locations:
    walk(ET.parse(book / 'locations' / f'{location}.xml').getroot(), location)
for photo in title.iter('photo'):
    use_camera(photo.get('camera'), None, photo.get('id'), 'photo')


# --- The scene: camera poses, briefs, text regions and anchor positions -----------------

def vec(node, name, fallback):
    value = node.get(name)
    return tuple(float(v) for v in value.split()) if value else fallback


rig, anchors = {}, {}


def collect(node, offset):
    for child in node:
        if child.tag == 'camera':
            rig[child.get('name')] = child
        elif child.get('name') or child.tag == 'group':
            position = tuple(o + v for o, v in zip(offset, vec(child, 'pos', (0, 0, 0))))
            if child.get('name'):
                anchors[child.get('name').lower().replace('_', '-')] = position
            collect(child, position)


for scene in sorted(rooms.glob('*.blks')) if rooms.is_dir() else []:
    collect(ET.parse(scene).getroot(), (0, 0, 0))


def project(camera, point, size):
    """Where an anchor lands on the picture: scene.c's projection, Z up."""
    pos, look = vec(camera, 'pos', (0, 160, 500)), vec(camera, 'look', (0, 120, 0))
    fov = float(camera.get('fov', 60))

    def sub(u, v): return tuple(x - y for x, y in zip(u, v))
    def dot(u, v): return sum(x * y for x, y in zip(u, v))
    def cross(u, v): return (u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0])
    def unit(u): return tuple(x / math.sqrt(dot(u, u)) for x in u)
    forward = unit(sub(look, pos))
    right = unit(cross(forward, (0, 0, 1)))
    up = cross(right, forward)
    delta = sub(point, pos)
    depth = dot(delta, forward)
    if depth <= 10:
        return None
    width, height = size
    focal = height / (2 * math.tan(math.radians(fov) / 2))
    x, y = width/2 + dot(delta, right) * focal / depth, height/2 - dot(delta, up) * focal / depth
    return (x, y) if 0 <= x <= width and 0 <= y <= height else None


# --- Drawing ---------------------------------------------------------------------------

def colour(location, value, saturation=.38):
    index = locations.index(location) if location in locations else len(locations)
    hue = (index * 0.618034) % 1
    return tuple(round(c * 255) for c in colorsys.hsv_to_rgb(hue, saturation, value))


def wrap(draw, text, face, width):
    lines = []
    for paragraph in text.split('\n'):
        line = ''
        for word in paragraph.split():
            trial = f'{line} {word}'.strip()
            if draw.textlength(trial, font=face) <= width or not line:
                line = trial
            else:
                lines.append(line)
                line = word
        lines.append(line)
    return lines


def block(draw, xy, text, face, width, fill, spacing=1.3):
    x, y = xy
    for line in wrap(draw, text, face, width):
        draw.text((x, y), line, font=face, fill=fill)
        y += face.size * spacing
    return y


def marker_of(path):
    if not path.is_file():
        return None
    match = re.search(rb'book-placeholder ([0-9a-f]+)', path.open('rb').read(MARKER_SCAN_BYTES))
    return match.group(1).decode() if match else ''


def stamp(*parts):
    return hashlib.sha1(repr((LAYOUT, parts)).encode()).hexdigest()[:12]


def fresh(path, digest):
    """True when the file is already this placeholder; False when it should be (re)made."""
    found = marker_of(path)
    if found == '' and not a.force:
        return True  # finished art
    return found == digest


def draw_still(name, info, size=STILL_SIZE):
    camera = rig.get(name)
    brief = camera.get('comment') if camera is not None else 'No camera in the scene: add one to the .blks rig.'
    location = info['location']
    image = Image.new('RGB', size, colour(location, .34))
    draw = ImageDraw.Draw(image)
    ink, faint = (240, 236, 226), colour(location, .62, .25)
    width, height = size
    if camera is not None and info['read']:
        for key in ('textRect', 'textRect2'):
            if camera.get(key):
                x, y, w, h = (float(v) for v in camera.get(key).split())
                draw.rectangle((x*width, y*height, (x+w)*width, (y+h)*height), outline=faint, width=2)
                draw.text((x*width + 8, (y+h)*height - 30), 'reading region', font=font(20, True), fill=faint)
    # Inside the crop every viewport keeps, below the icon row a conversation puts at the top;
    # on a document, under the reading region, where the app draws no prose.
    left, top = width * SAFE_SIDE, height * SAFE_TOP
    if camera is not None and info['read'] and camera.get('textRect'):
        x, y, w, h = (float(v) for v in camera.get('textRect').split())
        top = (y + h) * height + 16
    span = width * TITLE_WIDTH
    kinds = sorted({kind for _, kind in info['pages']})
    note = f"{location or 'photo'} · {', '.join(kinds)} · placeholder"
    lines = len(wrap(draw, brief, font(26, True), span))
    draw.rectangle((left - 16, top - 12, left + span + 16, top + 72 + lines * 34 + 40), fill=colour(location, .24))
    y = block(draw, (left, top), name, font(48), span, ink)
    y = block(draw, (left, y + 4), brief, font(26, True), span, ink)
    draw.text((left, y + 4), note, font=font(18), fill=faint)
    # The app captions each circle under it; the anchor's name and every label go beside it.
    for anchor, labels in sorted(info['anchors'].items()):
        point = anchors.get(anchor)
        at = project(camera, point, size) if camera is not None and point else None
        if not at:
            continue
        x, y = at
        draw.ellipse((x - 26, y - 26, x + 26, y + 26), outline=faint, width=3)
        draw.line((x - 10, y, x + 10, y), fill=faint, width=2)
        draw.line((x, y - 10, x, y + 10), fill=faint, width=2)
        text = f"{anchor}: {' / '.join(dict.fromkeys(labels))}"
        face = font(18)
        span = draw.textlength(text, font=face)
        tx = x + 36 if x + 36 + span <= width - left else x - 36 - span
        draw.text((tx, y - 11), text, font=face, fill=faint)
    return image


def draw_clip(name, uses):
    location = uses[0]['location']
    image = Image.new('RGB', CLIP_SIZE, colour(location, .20, .45))
    draw = ImageDraw.Draw(image)
    ink, faint = (240, 236, 226), colour(location, .58, .25)
    width, height = CLIP_SIZE
    left = width * SAFE_SIDE
    draw.text((left, 24), f'clip {name}', font=font(30), fill=ink)
    where = ', '.join(dict.fromkeys(f"{use['location']}/{use['page']}" for use in uses))
    y = block(draw, (left, 66), where, font(16, True), width - 2 * left, faint)
    texts = list(dict.fromkeys(use['text'] for use in uses if use['text']))
    text = texts[0] if texts else ''
    size = 26
    while size > 14 and len(wrap(draw, text, font(size), width - 2 * left)) * size * 1.3 > height - y - 70:
        size -= 1
    block(draw, (left, y + 18), text, font(size), width - 2 * left, ink)
    draw.text((left, height - 40), f"{uses[0]['camera']} · placeholder", font=font(16), fill=faint)
    words = len(text.split())
    seconds = min(max(1.5 + words / READING_WORDS_PER_SECOND, CLIP_SECONDS[0]), CLIP_SECONDS[1])
    return image, round(seconds, 1)


def draw_icon(ident, name, kind, text):
    image = Image.new('RGB', ICON_SIZE, colour(kind, .40, .30))
    draw = ImageDraw.Draw(image)
    ink = (240, 236, 226)
    face = font(64)
    lines = wrap(draw, name, face, ICON_SIZE[0] - 80)
    y = ICON_SIZE[1] / 2 - len(lines) * face.size * 0.65
    for line in lines:
        draw.text(((ICON_SIZE[0] - draw.textlength(line, font=face)) / 2, y), line, font=face, fill=ink)
        y += face.size * 1.3
    draw.text((40, ICON_SIZE[1] - 70), kind, font=font(30, True), fill=ink)
    return image


def save_jpeg(image, path, digest):
    image.save(path, 'JPEG', quality=88, comment=f'{MARKER} {digest}'.encode())


# --- Writing ---------------------------------------------------------------------------

rooms.mkdir(parents=True, exist_ok=True)
made, kept, wanted = [], 0, set()
for name, info in sorted(cameras.items()):
    path = rooms / f'{name}.jpg'
    wanted.add(path)
    camera = rig.get(name)
    digest = stamp(name, info['location'], sorted(info['anchors'].items()), sorted(info['pages']),
                   None if camera is None else sorted(camera.attrib.items()),
                   [(anchor, anchors.get(anchor)) for anchor in sorted(info['anchors'])])
    if fresh(path, digest):
        kept += 1
        continue
    save_jpeg(draw_still(name, info), path, digest)
    made.append(path.name)
for ident, name, kind, text in icons:
    path = rooms / f'item-{ident}.jpg'
    wanted.add(path)
    digest = stamp(ident, name, kind)
    if fresh(path, digest):
        kept += 1
        continue
    save_jpeg(draw_icon(ident, name, kind, text), path, digest)
    made.append(path.name)

if clip_pages and not a.stillclip:
    print('no --stillclip encoder: clips not made')
elif clip_pages:
    clips.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='placeholder-') as scratch:
        for name, uses in sorted(clip_pages.items()):
            path = clips / f'{name}.mp4'
            wanted.add(path)
            image, seconds = draw_clip(name, uses)
            digest = stamp(name, seconds, [sorted(use.items()) for use in uses])
            if fresh(path, digest):
                kept += 1
                continue
            frame = Path(scratch) / f'{name}.jpg'
            image.save(frame, 'JPEG', quality=92)
            subprocess.run([a.stillclip, str(frame), str(path), str(seconds), f'{MARKER} {digest}'], check=True)
            made.append(path.name)

pruned = []
for folder, suffix in ((rooms, '.jpg'), (clips, '.mp4')):
    for path in sorted(folder.glob(f'*{suffix}')) if folder.is_dir() else []:
        if path not in wanted and marker_of(path):
            path.unlink()
            pruned.append(path.name)
print(f'{a.book}: {len(made)} placeholders made, {kept} up to date or finished, {len(pruned)} stale removed')
for name in made:
    print(f'  made {name}')
for name in pruned:
    print(f'  removed {name}')
missing = sorted(name for name in cameras if name not in rig)
if missing:
    print(f"cameras with no pose in a .blks scene (anchors cannot be marked): {', '.join(missing)}")
