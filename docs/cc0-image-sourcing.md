# Mantle — CC0 / Public-Domain Deck Image Sourcing Guide

The affinity deck (`assets/images/deck/`, 8 images each for **architecture**, **tailoring**, **interiors**) is **bundled into this MIT app and redistributed**, so every image must be **CC0 or true Public Domain** — verified per-object. The build's content-validation test already refuses any deck record without a complete CC0/PD provenance block (`{institution, accessionId, sourceUrl, license, creator, title}`). This guide is the verified playbook for filling those 24 slots. **The v1 deck is now filled** with 24 real CC0/PD images (Cleveland CC0 + Met Public Domain) — see `assets/images/deck/manifest.json`. This guide remains the reference for any future re-source / deck expansion.

> Verified by a 5-angle, adversarially-checked research pass (June 2026): 23/25 license claims confirmed; 2 "it's all CC0" over-claims **refuted**.

## The hard rule (load-bearing)

**CC0 is applied PER-OBJECT, never collection-wide.** Every collection below mixes CC0/PD works with in-copyright or restricted works in the *same* API. You MUST filter on the correct per-record rights field for each image — "Open Access" or "in the collection" tells you nothing.

**CC0 waives copyright only** — not trademark, publicity, or privacy rights, and not the copyright of any work *depicted inside* the image. Prefer images **without recognizable living people or visible logos/brands**.

## Verified-clean true-CC0 sources

| Source | Per-object filter (mandatory) | Full-res image URL | Key? |
|---|---|---|---|
| **Met Museum** | `isPublicDomain == true` | `primaryImage` (direct JPEG) | none |
| **Art Institute of Chicago** | `is_public_domain == true` | IIIF: `{iiif_url}/{image_id}/full/843,/0/default.jpg` (read `iiif_url` from `/api/v1/artworks?fields=config.iiif_url`) | none |
| **Cleveland Museum of Art** | `cc0=1 & has_image=1` (or `share_license_status == "CC0"`) | `images.web.url` / `images.print.url` | none |
| **Smithsonian Open Access** | per-item rights == `CC0` (exclude **"Usage Conditions Apply"**) | IIIF / CC0 media URL | API key |
| **National Gallery of Art** | per-object open-access flag | per-object download/IIIF (images NOT in the GitHub metadata dump) | none |
| **Rijksmuseum** | rights == `CC0` **or** `Public Domain Mark` — **REJECT its CC BY 4.0 subset** | IIIF (docs carry no rights — must check object metadata) | API key |

Prefer **CC0-tagged** over PDM-only where both exist: the Public Domain Mark is a status *label* with "no legal effect," whereas CC0 is an explicit waiver.

## Hard-exclude (traps)

- CC BY, CC BY-SA, CC BY-NC, CC BY-ND (attribution / share-alike / non-commercial).
- **RightsStatements.org `NoC-NC`** ("No Copyright – Non-Commercial") and **`NoC-OKLR`** ("Other Known Legal Restrictions") — the "No Copyright" wording is **deceptive**; both are NOT redistribution-safe.
- Smithsonian "Usage Conditions Apply"; Rijksmuseum "CC BY 4.0"; any Unsplash/Pexels-licensed or "free to use" without an explicit CC0/PD grant.
- **Europeana** and **Wikimedia Commons** are heterogeneous aggregators (Europeana = 14 distinct rights statements; Commons = per-file). Accept ONLY the `CC0` and `Public Domain Mark` rights URIs; verify every individual file.

## Working pull recipe (Met, keyless — proven)

```bash
BASE="https://collectionapi.metmuseum.org/public/collection/v1"
ids=$(curl -s "$BASE/search?q=<term>&hasImages=true&departmentId=<dept>" | jq -r '.objectIDs[]')
for id in $ids; do
  obj=$(curl -s "$BASE/objects/$id")
  [ "$(echo "$obj" | jq -r .isPublicDomain)" = "true" ] || continue   # MANDATORY filter
  echo "$obj" | jq -c '{accessionNumber, title, artist:.artistDisplayName, primaryImage, objectURL}'
done
```

## Per-domain strategy (informed by what the first pulls revealed)

- **Tailoring is the hardest.** The Met **Costume Institute (dept 8) garments are almost entirely NON-public-domain** (mostly 20th-c., still in copyright) — a keyword+dept pull returned **0 CC0** garments. Source garments instead from: **CC0 fashion PLATES / costume prints** (Met Drawings & Prints, dept 9; Rijksmuseum/AIC costume prints), **textile/dress objects** at **Cooper Hewitt (Smithsonian)** filtered to CC0, or period **portraits** that clearly show dress (Met European Paintings, all `isPublicDomain`). Warm→austere: ornate court dress / embroidered garments → spare tailored coats.
- **Architecture.** Keyword `q=architecture` matches metadata, not façades — too loose. Better: Met **Photographs (dept 19)** for building exteriors (e.g. Charles Nègre, acc. **1998.132**, *The Refectory of the Imperial Asylum at Vincennes* — a real architectural interior photo, CC0), and **architectural engravings/prints** (Piranesi-style, warm) in Drawings & Prints; AIC architectural drawings. Warm→austere: classical/vernacular engravings → modernist/brutalist prints. (True-CC0 photos of *modern* buildings are the scarcest — lean on prints/drawings where needed.)
- **Interiors.** Dutch/Flemish genre interior **paintings** are ideal and abundant in CC0: e.g. **Emanuel de Witte, acc. 2001.403**, *Interior of the Oude Kerk, Delft* (Met, CC0). Search specific interior painters (de Witte, de Hooch) rather than `q=interior`. Warm→austere: cozy genre rooms → minimalist later interior studies.

## Curation checklist before bundling each image

1. Per-object CC0/PD flag verified (the exact field above) — not "open access".
2. Direct full-res image URL returns `200` + `image/*` (HEAD-check).
3. No recognizable living person; no visible logo/brand/depicted-copyrighted-artwork.
4. Provenance complete: `{institution, accessionId, sourceUrl, license:"CC0"|"Public Domain", creator, title}` → drop into `assets/images/deck/manifest.json`; download the file to `assets/images/deck/<id>.jpg`; the content-validation test enforces the rest.
5. Aim for the warm-traditional → austere-modern spread within each domain's 8 so the head-to-head ranking has real contrast.
