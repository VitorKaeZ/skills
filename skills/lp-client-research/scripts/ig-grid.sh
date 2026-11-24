#!/usr/bin/env bash
# Scrolls an Instagram profile grid and saves every post (code, kind, thumbnail, alt) as JSON.
# Usage: ig-grid.sh <username> <output.json> [resume]
# Uses BROWSER (default: browser.sh next to this script) for an already logged-in session.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
browser="${BROWSER:-$here/browser.sh}"
raw="${2%.json}.raw.jsonl"
if [[ "${3:-}" != "resume" ]]; then
  "$browser" open "https://www.instagram.com/$1/" >/dev/null 2>&1; sleep 5; : > "$raw"
fi
collect='JSON.stringify([...document.querySelectorAll("a[href*=\"/p/\"], a[href*=\"/reel/\"]")].map(a=>{const i=a.querySelector("img");if(!i)return null;const s=i.srcset?i.srcset.split(",").pop().trim().split(" ")[0]:i.src;return [a.getAttribute("href"),s,i.alt]}).filter(Boolean))'
count_posts() {
  python3 - "$raw" <<'PY'
import json,re,sys
codes=set()
for line in open(sys.argv[1]):
    line=line.strip()
    if line:
        for href,_,_ in json.loads(json.loads(line)):
            codes.add(re.search(r'/(p|reel)/([^/]+)',href).group(2))
print(len(codes))
PY
}
unchanged=0; last=0
for _ in $(seq 1 200); do
  "$browser" eval "$collect" 2>/dev/null | grep -v daemon >> "$raw" || true
  current=$(count_posts)
  if [[ "$current" == "$last" ]]; then unchanged=$((unchanged+1)); else unchanged=0; fi
  last=$current
  [[ $unchanged -ge 6 ]] && break
  "$browser" scroll down 2500 >/dev/null 2>&1; sleep 4
done
python3 - "$raw" "$2" <<'PY'
import json,re,sys
posts={}
for line in open(sys.argv[1]):
    line=line.strip()
    if not line: continue
    for href,thumb,alt in json.loads(json.loads(line)):
        match=re.search(r'/(p|reel)/([^/]+)',href)
        posts.setdefault(match.group(2),{'code':match.group(2),'kind':match.group(1),'thumb':thumb,'alt':alt})
json.dump(list(posts.values()),open(sys.argv[2],'w'),ensure_ascii=False,indent=1)
print(len(posts),'posts')
PY
