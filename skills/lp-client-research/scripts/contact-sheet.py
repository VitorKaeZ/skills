#!/usr/bin/env python3
"""Downloads post thumbnails from ig-grid.sh JSON and builds labelled contact sheets for picking.

Usage: contact-sheet.py <posts.json> <thumbs-dir> [--photos-only]
Sheets are written next to the thumbs dir as <thumbs-dir>_sheet_NN.jpg (needs ImageMagick).
"""
import json, os, subprocess, sys

PER_SHEET = 36

def main() -> None:
    source, thumbs_dir = sys.argv[1], sys.argv[2]
    posts = json.load(open(source))
    if '--photos-only' in sys.argv:
        posts = [p for p in posts if p['kind'] == 'p']
    os.makedirs(thumbs_dir, exist_ok=True)
    for index, post in enumerate(posts):
        path = f"{thumbs_dir}/{index:03d}_{post['kind']}_{post['code']}.jpg"
        if not os.path.exists(path):
            subprocess.run(['curl', '-s', '-A', 'Mozilla/5.0', '-o', path, post['thumb']])
    files = sorted(f for f in os.listdir(thumbs_dir) if f.endswith('.jpg'))
    for start in range(0, len(files), PER_SHEET):
        chunk = [f"{thumbs_dir}/{f}" for f in files[start:start + PER_SHEET]]
        subprocess.run(['montage', '-label', '%t', '-pointsize', '11', *chunk, '-geometry', '200x200+3+3',
                        '-tile', '6x', f"{thumbs_dir}_sheet_{start // PER_SHEET:02d}.jpg"], stderr=subprocess.DEVNULL)
    print(len(files), 'thumbnails')

if __name__ == '__main__':
    main()
