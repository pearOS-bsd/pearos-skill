<div align="center">

# pearOS Code Map

**A live 3D map of every line of code in the pearOS project, placed by meaning.**

[**Open the map →**](https://pearos-bsd.github.io/codemap/)

[![Live](https://img.shields.io/badge/live-pearos--bsd.github.io%2Fcodemap-7c9cff?style=flat-square)](https://pearos-bsd.github.io/codemap/)
[![Licence](https://img.shields.io/badge/licence-BSD--2--Clause-b48cff?style=flat-square)](LICENSE)
[![Organisation](https://img.shields.io/badge/github-pearOS--bsd-181717?style=flat-square&logo=github)](https://github.com/pearOS-bsd)

</div>

---

## What it shows

The map is a **3D radial tree** of the whole codebase: `pearOS` at the top, then the six architecture **layers**, the
**repositories** in each layer, their top-level **directories**, and every indexed **file** on the outer rings. Each
branch gets a slice of the circle proportional to the number of files under it, so big subsystems are visible at a glance.

| Element | Meaning |
|---|---|
| **Node colour** | The architecture layer (hue) and the repository inside it (shade) |
| **Node size** | How much indexed code is under it |
| **Gold curved edges** | **Near-duplicates**: two files in different repositories with chunks that are almost identical (cosine ≥ 0.90), so the same idea is implemented twice. Each one is a candidate for moving into the lowest layer that can own it |
| **Semantically closest files** (in the inspector) | Files whose code means the same thing, from the 768-dimension embeddings, whatever repository or language they are in |

## Using it

| Action | How |
|---|---|
| Rotate / zoom / pan | Drag · scroll · right-drag (or the touch equivalents) |
| Inspect | Click any node. A **file** lists its chunks (each one links to the exact lines on GitHub), its near-duplicates and its closest files. A **repository** lists what it shares with other repositories and its largest files |
| Open the source | **Open on GitHub** goes to `blob/main/<path>`, and each chunk to `#Lx-Ly` |
| Filter | Type a path, symbol or text (`/` focuses the field): matching files and their branches stay lit |
| Show or hide repositories | Click a repository in the sidebar; **only** isolates it and flies to it; layers fold |
| Share a view | **Copy link**: the URL hash (`#n=f:<repo>/<path>`, `#n=r:<repo>`) reopens the same node |
| Shortcuts | `R` fit · `A` auto-rotate · `D` duplicates · `L` labels · `T` theme · `F` full screen · `Esc` clear |

The page reloads `points.json` every minute and updates in place, keeping the camera and the selection. It has a dark
(default) and a light theme, respects *reduced motion*, and works on phones.

## Architecture layers

A lower layer never depends on a higher one. The map uses this order for colours and for the sidebar.

| Layer | Repositories |
|---|---|
| **L0** Kernel & ABI | `darwinator`, `IOKit` |
| **L1** Runtime & loader | `dyld`, `macdeps`, `libsystem`, `libdispatch`, `libobjc`, `libcxx`, `libxpc`, `swift-runtime`, `thirdparty`, `ploader` |
| **L2** Core frameworks | `CoreFoundation`, `Foundation`, `CoreGraphics`, `CoreText`, `ImageIO`, `Security`, `SystemConfiguration`, `CFNetwork`, `CoreServices`, `IconServices`, `LaunchServices`, `CoreUI`, `SDK`, … |
| **L3** UI & windowing | `SkyLight`, `WindowServer`, `QuartzCore`, `Solarium`, `UIFoundation`, `HIToolbox`, `AppKit`, `open` |
| **L4** Daemons & apps | `d`, `apps` |
| **Tooling** | `iso`, `tests`, `docs`, `research`, `pearos-skill` |

## How it is built

```
pearOS repositories ──► local Qdrant index ──► qdrant-map.py ──► points.json ──► this page
   (~/pearOS)          (one vector per chunk)   (UMAP → 3D,        (static,        (3d-force-graph,
                                                 duplicates ≥ 0.90)  ~1 MB)          GitHub Pages)
```

1. Every repository is indexed into a local [Qdrant](https://qdrant.tech) instance, one vector per code chunk.
2. [`scripts/qdrant-map.py`](https://github.com/pearOS-bsd/pearos-skill/blob/main/scripts/qdrant-map.py) exports all
   vectors, reduces them to 3D with UMAP (cosine metric; PCA if UMAP is missing; used for “closest files”) and finds the
   cross-repository near-duplicates. The page builds the layer → repository → directory → file tree from the paths.
3. [`scripts/map-publish.sh`](https://github.com/pearOS-bsd/pearos-skill/blob/main/scripts/map-publish.sh) copies
   the page from [`site/`](https://github.com/pearOS-bsd/pearos-skill/tree/main/site) and force-pushes one orphan
   commit here, so this repository never grows.

**Do not edit this repository by hand.** It is regenerated on every publish. Change the page in
[`pearos-skill/site/index.html`](https://github.com/pearOS-bsd/pearos-skill/blob/main/site/index.html), then run:

```sh
sh scripts/map-publish.sh      # in pearos-skill, with Qdrant running on localhost:6333
```

### `points.json` format

| Key | Type | Meaning |
|---|---|---|
| `updated` | number | Unix time of the export |
| `repos`, `files` | string[] | Lookup tables (`files` entries are `<repo>/<path>`) |
| `x`, `y`, `z` | number[] | Position of each chunk |
| `r`, `f` | int[] | Repository / file index of each chunk |
| `l`, `e` | int[] | First / last line of each chunk |
| `t` | string[] | The first 110 characters of each chunk |
| `links` | `[a, b, cosine][]` | Cross-repository near-duplicates (chunk indices) |

## Licence

BSD-2-Clause. See [LICENSE](LICENSE). The page loads [3d-force-graph](https://github.com/vasturiano/3d-force-graph) (MIT, bundles three.js) from jsDelivr.
