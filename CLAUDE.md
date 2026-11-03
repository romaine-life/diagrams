# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Overview

diagrams is an interactive architecture documentation site (at `diagrams.romaine.life`) for Nelson's Azure app ecosystem at romaine.life. It uses React Flow to visualize how apps connect to platform infrastructure, app-owned Key Vaults, CI/CD, and external services with per-app filtering and clickable annotations.

**Read `D:/shell-config/setup/claude/CLAUDE.md` for global Claude config, profile dispatch, skills, and memory rules.**

## Container Build Verification

Agent pods are not expected to have Docker. Do not report missing local Docker
as a blocker. Run available repo checks first, then use PR CI as the normal
container build gate: `.forgejo/workflows/docker-build-check.yaml` performs a
throwaway Docker build with `push: false`. If image-packaging feedback is
needed before a PR is ready, manually dispatch that workflow with `git_ref`.
Release/deploy workflows are the only path that publishes images.

## Scratch Workspace Guard Rails

When local filesystem access is helpful for drafting, validation, or temporary analysis:

- Treat `D:\repos\...` checkouts as read-only reference context.
- Do not edit tracked files in place under `D:\repos\...` unless the user explicitly approves that exact exception.
- Prefer a disposable workspace outside the repo tree, such as `D:\automation\scratch\...`.
- Publish the final repository change through Forgejo-backed tools only.
- Delete or discard the scratch workspace after the remote change is published.
- Avoid local `git` commands entirely for repo work unless the user explicitly approves that exact exception.

## Tech Stack

- React 19, TypeScript, Vite 8
- Tailwind CSS v4 (`@tailwindcss/postcss`)
- React Flow (`@xyflow/react`) for interactive diagrams
- React Router for URL-based app filtering
- lucide-react for icons

## Project Structure

```
frontend/src/
  components/     React components (DiagramView, AppNode, InfraNode, DetailPanel, AppFilter)
  data/           Architecture data (nodes.ts, edges.ts, annotations.ts)
  types.ts        Shared TypeScript types
  index.css       Tailwind v4 + React Flow dark theme overrides
k8s/              Helm chart for the AKS deployment
tofu/             OpenTofu IaC — app Key Vault, CI identity, and supporting Azure resources
.forgejo/workflows/
  build-and-deploy.yaml   Build and smoke-test image, publish, then merge a checked image-pin PR
  docker-build-check.yaml Build and smoke-test the container on PRs
  tofu.yaml              Plan on PR, apply infrastructure on main or manual dispatch
  lint.yaml              Repository conventions, TypeScript build and ESLint
```

## Views

- **`/`** — Main infrastructure diagram (React Flow) showing apps, shared infra, external services, CI/CD
- **`/:app`** — Filtered view highlighting a single app's path through infrastructure
- **`/pipelines`** — Pipeline dependency diagram showing cross-repo CI/CD chains (fzt → my-homepage / fzt-showcase) with the dispatch/artifact flow
- **`/ci/codex`** — Codex Queue status and event stream. This separate automation feature retains its signing secret and backend routes.

The unused CI dependency dashboard, GitHub webhook ingestion, release backfill and deployed-version reporting were retired in FORGEJO-3. Former dashboard endpoints under `/ci` return 404.

## Navigation

`NavSidebar` component — persistent collapsible right-side panel with route list grouped by section. Present on all pages. Footer fetches `/version.json` when a deployed app serves it and renders the 7-char SHA linked to the Forgejo commit plus a relative timestamp ticking every 60s. The footer hides if `/version.json` 404s (dev mode); `frontend/public/version.json` is gitignored so dev fixtures don't get committed.

## Architecture Data

All diagram content lives in `src/data/`:

- **nodes.ts** — Every box on the diagram (apps, shared infra, external services, CI/CD). Each node has a `category` and `apps[]` array that drives filtering.
- **edges.ts** — Connections between nodes with color-coded styles per category.
- **annotations.ts** — Click-to-read narrative text for each node. This is where the "why" lives — not just what exists, but why it's architected that way.
- **pipeline-nodes.ts** — Nodes for the `/pipelines` view (repos, workflows, artifacts, issues).
- **pipeline-edges.ts** — Edges for the `/pipelines` view with color-coded styles: amber (dispatch), blue (internal), purple (artifact), red dashed (broken).

To add a new app or infra component: add a node in nodes.ts, wire edges in edges.ts, write an annotation in annotations.ts. The diagram updates automatically.

## Commands

- `npm run dev` — Dev server on port 5505
- `npm run build` — TypeScript check + Vite production build
- `npm run lint` — ESLint
