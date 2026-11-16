---
description: Licence audit of what goes into the image (GPL libraries, Apple files, upstream provenance)
---
Run `iso/licenses/audit.sh` on the FreeBSD VM image tree (or /). Also check: no Apple file tracked in any repo (`git ls-files | grep -iE '\.car$|dyld_shared|\.dylib$'` outside `CoreUI`), every `upstream/` folder listed in PROVENANCE.md with licence. Report failures; fix the table `licenses/libs.tsv` only with a real licence check.
