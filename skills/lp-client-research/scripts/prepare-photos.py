#!/usr/bin/env python3
"""Builds form/photos/<section>/<slot>.webp plus optimized alternatives from a selection plan.

Usage: prepare-photos.py <client-root> <plan.py>

The plan is a Python literal: {section_folder: {slot: (chosen, [alternatives])}}. A reference is either a
post image name under assets/instagram/full (e.g. 'Abc123_01') or a path under assets/ (e.g.
'google_profile/storefront.jpg'). Example:
{'01_hero': {'hero': ('Abc123_01', ['Def456_01'])},
 '05_gallery': {'gallery1': ('Ghi789_01', [])}}
"""
import glob, os, shutil, subprocess, sys

MAX_SIDE = '2400x2400>'
MAX_BYTES = 1_450_000

def resolve(assets: str, ref: str) -> str:
    if '/' in ref:
        return f"{assets}/{ref}"
    matches = sorted(glob.glob(f"{assets}/instagram/full/{ref}.*"))
    if not matches:
        raise SystemExit(f"missing image: {ref}")
    return matches[0]

def optimize(source: str, target: str) -> None:
    for quality in (85, 80, 75, 70, 60, 50):
        subprocess.run(['convert', source + '[0]', '-auto-orient', '-resize', MAX_SIDE, '-strip',
                        '-quality', str(quality), target], check=True)
        if os.path.getsize(target) <= MAX_BYTES:
            return
    raise SystemExit(f"still too big: {target}")

def main() -> None:
    root, plan_file = sys.argv[1], sys.argv[2]
    plan = eval(open(plan_file).read(), {'__builtins__': {}})
    assets, out = f"{root}/assets", f"{root}/form/photos"
    shutil.rmtree(out, ignore_errors=True)
    for folder, slots in plan.items():
        os.makedirs(f"{out}/{folder}/alternatives", exist_ok=True)
        for slot, (chosen, alternatives) in slots.items():
            optimize(resolve(assets, chosen), f"{out}/{folder}/{slot}.webp")
            for alt in alternatives:
                name = os.path.basename(os.path.splitext(alt)[0])
                optimize(resolve(assets, alt), f"{out}/{folder}/alternatives/{slot}_alt_{name}.webp")
            print(folder, slot, chosen)

if __name__ == '__main__':
    main()
