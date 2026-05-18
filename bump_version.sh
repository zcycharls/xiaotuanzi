#!/bin/bash
# 每次提交前自动更新版本号
VERSION="1.$(date +%m%d).$(date +%H%M)"
python3 -c "
import json
with open('package.json') as f: pkg=json.load(f)
pkg['version']='$VERSION'
with open('package.json','w') as f: json.dump(pkg,f,indent=2,ensure_ascii=False)
print('Version bumped to $VERSION')
"
