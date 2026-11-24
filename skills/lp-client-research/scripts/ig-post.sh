#!/usr/bin/env bash
# Downloads the full-size images of Instagram posts, walking carousels with the "Avançar"/"Next" button.
# Usage: ig-post.sh <output-dir> <code>...
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
browser="${BROWSER:-$here/browser.sh}"
out="$1"; shift; mkdir -p "$out"
collect='JSON.stringify([...document.querySelectorAll("main img, article img, div[role=dialog] img")].filter(i=>/^(Photo|Video|Foto)/i.test(i.alt)||/Pode ser/.test(i.alt)).map(i=>{const s=i.srcset?i.srcset.split(",").map(x=>x.trim().split(" ")):[[i.src]];return [s[s.length-1][0],i.alt]}).filter(x=>/cdninstagram|fbcdn/.test(x[0])))'
seen_file="$(mktemp)"; trap 'rm -f "$seen_file"' EXIT
for code in "$@"; do
  "$browser" open "https://www.instagram.com/p/$code/" >/dev/null 2>&1; sleep 5
  "$browser" press Escape >/dev/null 2>&1 || true
  : > "$seen_file"
  for _ in $(seq 1 10); do
    "$browser" eval "$collect" 2>/dev/null | grep -v daemon >> "$seen_file" || true
    "$browser" find label "Avançar" click >/dev/null 2>&1 || "$browser" find label "Next" click >/dev/null 2>&1 || break
    sleep 1.2
  done
  python3 - "$seen_file" "$out" "$code" <<'PY'
import json,re,subprocess,sys
seen_file,out,code=sys.argv[1:4]
urls=[];names=set();alt=''
for line in open(seen_file):
    line=line.strip()
    if not line: continue
    for url,a in json.loads(json.loads(line)):
        name=re.sub(r'\?.*','',url).split('/')[-1]
        if name in names or 's150x150' in url or 's640x640' in url: continue
        names.add(name); urls.append(url); alt=alt or a
for index,url in enumerate(urls[:10],1):
    path=f'{out}/{code}_{index:02d}.jpg'
    subprocess.run(['curl','-s','-A','Mozilla/5.0','-o',path,url],check=True)
    kind=subprocess.run(['file','-b',path],capture_output=True,text=True).stdout
    if 'Web/P' in kind: subprocess.run(['mv',path,path[:-4]+'.webp'])
print(code,len(urls),alt[:90])
PY
  sleep 2
done
