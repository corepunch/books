#!/usr/bin/env python3
"""Read Огонь на маяке through its headless page interface: every page, route, ending and retry."""
from pathlib import Path
import re
import sys

from headless_book import Book as HeadlessBook

binary, root = (Path(value).resolve() for value in sys.argv[1:3])
source = (root / 'books/lighthouse.c').read_text()
page_ids = set(re.findall(r'\{\.id = "([^"]+)"', source))
checks = set(re.findall(r'\{\.id = "([^"]+)", \.kind = STORY_CHECK', source))
cameras = set(re.findall(r'\.camera = "([^"]+)"', source))


def Book():
    return HeadlessBook(binary, root, 'lighthouse')


def follow(book, route):
    """Replay a route of choice commands; 'continue' taps the Continue button."""
    for command in route:
        if command == 'continue':
            book.continue_page()
        else:
            book.choose(command)
    return book.view


# Explore every reachable page from the opening. Hidden facts depend on the pages already seen, so a
# page is explored again whenever it is reached with a different history.
seen, explored, endings, frontier = {}, set(), {}, [([], frozenset())]
while frontier:
    route, past = frontier.pop()
    book = Book()
    view = follow(book, route)
    book.close()
    state = (view['kind'], view['image'], view['text'], tuple(c['command'] for c in view['choices']))
    if (state, past) in explored:
        continue
    explored.add((state, past))
    seen.setdefault(state, route)
    past = past | {state}
    assert Path(view['image']).is_file(), f'missing picture for {route}: {view["image"]}'
    if view['kind'] == 'ended':
        endings[Path(view['image']).stem] = (view['ending'], route)
    elif view['kind'] == 'beat':
        frontier.append((route + ['continue'], past))
    else:
        assert 2 <= len(view['choices']) <= 3, (route, view['choices'])
        frontier.extend((route + [choice['command']], past) for choice in view['choices'])

reached_cameras = {Path(state[1]).stem for state in seen}
assert reached_cameras == cameras, (cameras - reached_cameras, reached_cameras - cameras)
kinds = sorted(kind for kind, _ in endings.values())
assert kinds.count('success') == 1 and kinds.count('partial') == 1 and kinds.count('failure') >= 4, endings

# A failure ending offers "try again" and returns to the last decision with the facts of that moment.
book = Book()
follow(book, ['continue', 'continue', 'harbour', 'continue', 'flats', 'continue', 'wreck', 'continue', 'end-wreck'])
assert book.view['kind'] == 'ended' and book.view['ending'] == 'failure'
assert [(c['kind'], c['label']) for c in book.view['choices']] == [('retry', 'Попробовать снова')]
assert book.view['choices'][0]['command'] == 'wreck-decide'
ending = book.view
for ignored in (':continue', ':back', 'harbour', ':choose 5'):
    assert book.send(ignored) == ending
book.tap_choice(0)
assert book.view['kind'] == 'room' and Path(book.view['image']).stem == 'flats-show-tide'
assert {c['command'] for c in book.view['choices']} == {'flats-run', 'end-wreck'}
book.close()

# Facts survive a retry: the seal helps on the stones only if Varya followed it first.
book = Book()
follow(book, ['continue', 'continue', 'harbour', 'continue', 'flats', 'continue', 'seal-bar', 'continue',
              'stones'])
assert Path(book.view['image']).stem == 'channel-stones-seal'
book.close()
book = Book()
follow(book, ['continue', 'continue', 'harbour', 'continue', 'cliffs', 'continue', 'bridge', 'bridge-over',
              'continue', 'ask-ferry'])
assert Path(book.view['image']).stem == 'channel-talk-ferryman' and 'Ни за что' in book.view['text']
follow(book, ['continue'])
assert {c['command'] for c in book.view['choices']} == {'stones', 'end-hut'}  # he will not be asked twice
follow(book, ['stones', 'end-stones'])
book.tap_choice(0)  # try again from the middle of the stones, still refused
assert Path(book.view['image']).stem == 'channel-stones-mid'
follow(book, ['ferry-relent', 'continue', 'continue', 'continue', 'continue', 'end-light'])
assert book.view['ending'] == 'success'
assert [(c['kind'], c['label']) for c in book.view['choices']] == [('retry', 'Начать сначала')]
book.tap_choice(0)
assert Path(book.view['image']).stem == 'home-show-grandpa' and book.view['kind'] == 'beat'
book.close()

# Agafya's word gets Varya the ferry; the golden path by the cliffs.
book = Book()
follow(book, ['continue', 'continue', 'harbour', 'continue', 'cliffs', 'continue', 'sheep-track', 'continue',
              'ask-ferry'])
assert 'Агафья велела' in book.view['text']
book.close()

# The same authored reading areas must fit the supported landscape iPad shapes.
for viewport in ((1024, 768), (1133, 744), (1366, 1024)):
    for route in seen.values():
        book = HeadlessBook(binary, root, 'lighthouse', viewport)
        follow(book, route)
        book.close()

print(f'Lighthouse: {len(seen)} page states, {len(cameras)} pictures, {len(endings)} endings and retries passed')
