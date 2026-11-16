#!/usr/bin/env python3
"""mhalder/qdrant-mcp-server ignores CODE_CUSTOM_IGNORE / CODE_CUSTOM_EXTENSIONS in the version we build (the settings never reach the scanner).
Patch build/index.js so both variables work.  Idempotent.  usage: python3 patches/mcp-env-ignore.py ~/.pear/qdrant-mcp-server/build/index.js"""
import sys
p=sys.argv[1]; s=open(p).read()
if 'CODE_CUSTOM_IGNORE' in s: print('already patched'); sys.exit(0)
a="    supportedExtensions: DEFAULT_CODE_EXTENSIONS,\n    ignorePatterns: DEFAULT_IGNORE_PATTERNS,\n"
assert a in s, 'unexpected server version'
b=("    supportedExtensions: [...new Set([...DEFAULT_CODE_EXTENSIONS, ...(process.env.CODE_CUSTOM_EXTENSIONS || \"\").split(\",\").map((x) => x.trim()).filter(Boolean)])],\n"
   "    ignorePatterns: DEFAULT_IGNORE_PATTERNS,\n"
   "    customIgnorePatterns: (process.env.CODE_CUSTOM_IGNORE || \"\").split(\",\").map((x) => x.trim()).filter(Boolean),\n")
open(p,'w').write(s.replace(a,b,1)); print('patched')
