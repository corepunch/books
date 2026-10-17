#!/usr/bin/env python3
"""Play tests/fixture, a book that uses every X-Files feature the runtime plays, on The Salt
Ledger's pictures and clips; then read it with the book tool."""
from pathlib import Path
import json
import os
import subprocess
import sys
import tempfile

from headless_book import Book

binary, cli, root = (Path(value).resolve() for value in sys.argv[1:4])
fixture = Path(__file__).resolve().parent / 'fixture'
salt = root / 'books/salt'


def labels(view):
    return [c['label'] for c in view['choices'] if c['kind'] in ('object', 'ask', 'end')]


def items(view):
    return [c['command'] for c in view['choices'] if c['kind'] == 'item']


def choose(book, label):
    index = next(i for i, c in enumerate(book.view['choices']) if c['label'] == label and c['kind'] != 'item')
    return book.send(f':choose {index}')


with tempfile.TemporaryDirectory(prefix='book-engine-') as directory:
    book_dir = Path(directory) / 'books' / 'fixture'
    (book_dir / 'locations').mkdir(parents=True)
    for source in [fixture / 'title.xml', *sorted((fixture / 'locations').glob('*.xml'))]:
        target = book_dir / source.relative_to(fixture)
        target.write_text(source.read_text())
    rooms = book_dir / 'rooms'
    rooms.mkdir()
    for picture in (salt / 'rooms').iterdir():
        os.symlink(picture, rooms / picture.name)
    for icon in ('peg', 'hour', 'calm', 'badge'):
        os.symlink(salt / 'rooms/item-ledger.jpg', rooms / f'item-{icon}.jpg')
    os.symlink(salt / 'clips', book_dir / 'clips')
    for shared in ('fonts', 'assets'):
        os.symlink(root / shared, Path(directory) / shared)

    book = Book(binary, directory, 'fixture')
    view = book.view
    # A clip slice: from 500 ms to 2500 ms of visit.mp4.
    assert view['id'] == 'arrive' and view['clip'].endswith('/clips/visit.mp4'), view
    assert (view['clip_from'], view['clip_to'], view['loop']) == (500, 2500, False), view
    view = book.continue_page()
    # A view in a viewpoint: a looping clip, a turn on the right edge, a disabled lamp, no harbour yet.
    assert view['id'] == 'desk' and view['loop'] and view['clip'].endswith('/clips/window.mp4'), view
    assert labels(view) == ['The folder', 'The telephone', 'The ledger', 'Turn right'], labels(view)
    turn = next(c for c in view['choices'] if c['label'] == 'Turn right')
    assert turn['edge'] == 'right', turn
    control = next(c for c in view['controls'] if view['choices'][c['choice']]['label'] == 'Turn right')
    assert control['x'] > book.width * .8, control
    # Ideas and emotions are carried but only shown in a conversation.
    assert items(view) == [], items(view)
    # Actions without a target: the page stays and shows what changed.
    view = choose(book, 'The telephone')
    assert view['id'] == 'desk'
    assert labels(view) == ['The folder', 'The lamp', 'The telephone', 'The ledger', 'Turn right', 'To the harbour']
    assert items(view) == ['peg'], items(view)
    # The PDA: the telephone delivered an email and a photo; the phone does not answer yet.
    assert [c['kind'] for c in view['choices']].count('pda') == 1
    view = book.tap_choice(next(i for i, c in enumerate(view['choices']) if c['kind'] == 'pda'))
    assert view['id'] == 'pda' and view['talk'], view
    assert labels(view) == ['Notes (0)', 'Email (1 new)', 'Photos (1 new)', 'Phone', 'Close'], labels(view)
    view = choose(book, 'Email (1 new)')
    assert view['id'] == 'pda-email' and labels(view) == ['New: Background, from Cook', 'Back'], labels(view)
    view = choose(book, 'New: Background, from Cook')
    assert view['id'] == 'mail' and view['read'] and view['text'] == 'From Cook: Background\nWong has no record.', view
    view = book.continue_page()
    assert view['id'] == 'pda-email' and labels(view) == ['Background, from Cook', 'Back'], labels(view)
    view = choose(book, 'Back')
    view = choose(book, 'Photos (1 new)')
    view = choose(book, 'New: The lamp')
    assert view['id'] == 'snap' and Path(view['image']).stem == 'window', view['image']
    assert view['text'] == 'The lamp\nThe man under the lamp.', view['text']
    view = book.continue_page()
    view = choose(book, 'Back')
    view = choose(book, 'Phone')
    assert view['keypad'] and [c['label'] for c in view['choices'] if c['kind'] == 'key'] == \
        ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'Clear', '0', 'Dial'], view['choices']
    for digit in '2065550182':
        view = book.choose(f'pda:key:{digit}')
    assert view['text'] == 'Dial 2065550182', view['text']
    view = book.choose('pda:dial')
    assert view['id'] == 'pda-phone' and view['text'] == 'No one answers.', view['text']
    view = choose(book, 'Back')
    view = choose(book, 'Close')
    assert view['id'] == 'desk' and 'The lamp' in labels(view), labels(view)
    # An end trigger: calm, so the action list copies the caller and returns to the desk.
    view = choose(book, 'The lamp')
    assert view['id'] == 'lamp-shot'
    view = book.continue_page()
    assert view['id'] == 'desk', view['id']
    # Turning, then a charview inside the view: its circle plays the greeting first.
    view = choose(book, 'Turn right')
    assert view['id'] == 'window-side' and labels(view) == ['Turn left', 'The folder', 'Edith'], labels(view)
    view = choose(book, 'Edith')
    assert view['id'] == 'edith-greet'
    view = book.continue_page()
    assert view['id'] == 'edith-talk' and view['kind'] == 'room', view
    assert labels(view) == ['Thomas?', 'Goodbye'] and items(view) == ['peg', 'hour', 'calm'], (labels(view), items(view))
    # A conversation's reply plays and returns; its line is spent.
    view = choose(book, 'Thomas?')
    assert view['id'] == 'ask-thomas' and view['clip'].endswith('/clips/marsh-voss.mp4')
    view = book.continue_page()
    assert view['id'] == 'edith-talk' and labels(view) == ['Goodbye']
    # A topic (idea) offers its line; a reply may be a slice.
    view = book.hold('hour')
    assert labels(view) == ['His hour', 'Goodbye'], labels(view)
    view = choose(book, 'His hour')
    assert view['id'] == 'ask-hour' and view['clip_from'] == 1000 and view['clip_to'] == 0
    view = book.continue_page()
    assert view['id'] == 'edith-talk'
    # A tone (emotion) runs an action list. The third visit makes the desk tense.
    view = book.hold('calm')
    view = choose(book, 'Calmly')
    assert view['id'] == 'desk'
    view = choose(book, 'The lamp')
    view = book.continue_page()
    assert view['id'] == 'ending-tense' and view['ending'] == 'failure', view
    # Retry restores the world as it was at the desk: still tense, still holding the peg.
    view = book.retry()
    assert view['id'] == 'desk' and items(view) == ['peg'], items(view)
    # Take the ledger; a document keeps paragraphs.
    view = choose(book, 'The ledger')
    assert view['id'] == 'desk' and items(view) == ['ledger', 'peg'] and 'The ledger' not in labels(view)
    view = choose(book, 'The folder')
    assert view['read'] and view['text'] == 'Thomas Voss, tide clerk.\nBerth four.', view['text']
    view = book.continue_page()
    # Travel by map into the next node; leaving the office calms the reader again.
    view = choose(book, 'To the harbour')
    assert view['id'] == 'harbour-map' and view['kind'] == 'room' and labels(view) == ['Berth four', 'The office']
    # Entering the harbour's node showed the organizer; its item enables a note and goes home.
    view = book.choose('pda')
    assert labels(view) == ['Notes (0)', 'Email (1)', 'Photos (1)', 'Phone', 'Organizer', 'Close'], labels(view)
    view = choose(book, 'Organizer')
    assert view['id'] == 'organizer' and labels(view) == ['Notes', 'Back'], labels(view)
    view = choose(book, 'Notes')
    assert view['id'] == 'desk', view['id']
    view = book.choose('pda')
    view = choose(book, 'Notes (1 new)')
    view = choose(book, 'New: Berth four')
    assert view['text'] == 'Berth four\nThomas kept the tide at berth four.', view['text']
    view = book.continue_page()
    view = choose(book, 'Back')
    view = choose(book, 'Close')
    view = choose(book, 'The lamp')
    view = book.continue_page()
    assert view['id'] == 'desk', 'the dock should have calmed the reader'
    # Edith has talked about Thomas, so the number answers now.
    view = book.choose('pda')
    view = choose(book, 'Phone')
    for digit in '2065550182':
        view = book.choose(f'pda:key:{digit}')
    view = book.choose('pda:dial')
    assert view['id'] == 'phone-call', view['id']
    view = book.continue_page()
    assert view['id'] == 'desk'
    view = choose(book, 'To the harbour')
    view = choose(book, 'Berth four')
    # visited() and has() together open the last circle.
    assert view['id'] == 'berth' and 'The book' in labels(view), labels(view)
    view = choose(book, 'The book')
    assert view['id'] == 'ending-best' and view['ending'] == 'success'
    book.close()

    def tool(*args, ok=True):
        command, *rest = args
        result = subprocess.run([str(cli), command, 'fixture', *rest, '--root', directory], capture_output=True, text=True)
        assert (result.returncode == 0) == ok, (args, result.stdout, result.stderr)
        return result.stdout

    assert tool('check').endswith(': ok\n')
    stats = json.loads(tool('stats', '--json'))
    total = stats['total']
    assert (total['viewpoints'], total['maps'], total['charviews'], total['actionlists']) == (1, 1, 1, 1), total
    assert total['icons_by_kind'] == {'inventory': 1, 'evidence': 1, 'idea': 1, 'emotion': 1, 'action-icon': 1}, total
    assert total['records'] == {'note': 1, 'email': 1, 'photo': 1, 'phone': 1, 'interface': 1}, total
    assert total['variables'] == {'bool': 2, 'int': 2, 'char': 1, 'string': 2}, total
    assert 'dial 206-555-0182 -> phone-call if talked' in tool('query', '206-555-0182')
    assert 'item "Notes" -> desk' in tool('query', 'organizer') and 'shows it' in tool('query', 'organizer')
    assert 'starts disabled' in tool('query', 'lamp') and 'enables it' in tool('query', 'lamp')
    assert 'tests it: if mood' in tool('query', 'mood')
    assert 'facing e' in tool('query', 'desk-spot')
    played = tool('play', 'continue', 'desk:2')
    assert '-> harbour-map' in played.split('\n> desk:2\n')[1], played
    graph = tool('graph')
    assert 'variable arrivals is set but never tested' in graph and 'icon badge can never be had' in graph, graph

print('Engine: slices, loops, turns, flags, triggers, action lists, charviews, topics, tones, evidence, '
      'travel, retry, the PDA (notes, email, photos, phone, interfaces) and the book tool passed')
