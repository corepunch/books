#!/usr/bin/env python3
"""The book tool on an XML book: each command, and loader errors that name file and line."""
from pathlib import Path
import json
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

cli, root = (Path(value).resolve() for value in sys.argv[1:3])
name = sys.argv[3]
book = root / 'books' / name


def run(*args, at=root, ok=True):
    command, *rest = args
    result = subprocess.run([str(cli), command, name, *rest, '--root', str(at)], capture_output=True, text=True)
    assert (result.returncode == 0) == ok, (args, result.stdout, result.stderr)
    return result.stdout if ok else result.stderr


title = ET.parse(book / 'title.xml').getroot()
locations = [location.get('id') for location in title.iter('location')]
files = {location: book / 'locations' / f'{location}.xml' for location in locations}
pages = [page for location in locations for page in ET.parse(files[location]).getroot().iter() if page.get('id')
         and page.tag not in ('location', 'viewpoint')]

assert run('check').endswith(': ok\n')
stats = json.loads(run('stats', '--json'))
assert stats['total']['pages'] == len(pages)
assert [location['location'] for location in stats['locations']] == locations
assets = json.loads(run('assets', '--json'))
assert not [asset for asset in assets['assets'] if asset['status'] == 'missing'], assets
assert json.loads(run('assets', '--missing', '--json'))['assets'] == []
assert 'findings' in run('graph') and run('graph', '--dot').startswith('digraph')
start = title.get('start')
assert f'] {start}' in run('play').splitlines()[0]
assert 'reached from' in run('query', start)
variable = title.find('variable').get('id')
assert run('query', variable).startswith('variable\n')
assert 'nothing called' in run('query', 'no-such-name', ok=False)


def edited(edit, *command, ok=False):
    """Copy the book's XML, apply one edit, and return the tool's output, or its complaint."""
    with tempfile.TemporaryDirectory(prefix='book-cli-') as directory:
        copy = Path(directory) / 'books' / name
        copy.mkdir(parents=True)
        shutil.copy(book / 'title.xml', copy / 'title.xml')
        shutil.copytree(book / 'locations', copy / 'locations')
        edit(copy)
        return run(*(command or ('stats',)), at=Path(directory), ok=ok)


def broken(edit):
    return edited(edit)


def replace(path, old, new):
    text = path.read_text()
    assert old in text, (path, old)
    path.write_text(text.replace(old, new, 1))


asset = next(page for page in pages if page.tag == 'asset' and page.get('next'))
home = next(location for location in locations if f'id="{asset.get("id")}"' in files[location].read_text())
path = f'locations/{home}.xml'
error = broken(lambda copy: replace(copy / path, f'id="{asset.get("id")}"', f'id="{asset.get("id")}" sets="no-such-variable"'))
assert f'{path}:' in error and 'no variable is named "no-such-variable"' in error, error
error = broken(lambda copy: replace(copy / path, f'id="{asset.get("id")}"', f'id="{asset.get("id")}" colour="red"'))
assert 'has no attribute colour' in error, error
error = broken(lambda copy: (copy / 'locations' / 'stray.xml').write_text('<location id="stray"/>'))
assert 'stray.xml is not listed' in error, error
error = broken(lambda copy: replace(copy / path, 'next="', 'next="no-such-page-'))
assert f'{path}:' in error and 'names no page "no-such-page-' in error, error
error = broken(lambda copy: replace(copy / 'title.xml', f'<location id="{locations[-1]}"/>',
                                    f'<location id="{locations[-1]}"/><location id="{locations[0]}"/>'))
assert 'listed twice' in error, error
error = broken(lambda copy: replace(copy / path, f'id="{asset.get("id")}"', f'id="{asset.get("id")}" sets="{variable}" read="maybe"'))
assert 'read must be true or false' in error, error

# <region/> begins the next reading region: a form feed, with no space beside it.
words = (asset.text or '').split()
output = edited(lambda copy: replace(copy / path, f'{words[0]} {words[1]}', f'{words[0]} <region/> {words[1]}'),
                'query', asset.get('id'), ok=True)
assert f'{words[0]}\f{words[1]}' in output, output
# A blank line between words begins a paragraph: a newline in the page text.
output = edited(lambda copy: replace(copy / path, f'{words[0]} {words[1]}', f'{words[0]}\n\n    {words[1]}'),
                'query', asset.get('id'), ok=True)
assert f'{words[0]}\n{words[1]}' in output, output

print(f'Book tool: check, stats, graph, query, play and assets on {name}, six loader errors, regions and paragraphs passed')
