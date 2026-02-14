# Obsidian Unofficial Plugins Registry

This repository automatically generates an unofficial registry of Obsidian plugins and themes by scraping pull requests from the [obsidian-releases](https://github.com/obsidianmd/obsidian-releases) repository. It is designed to capture plugins and themes that are currently in the review process or otherwise not yet in the official community list.

## How it works

The core logic is in `getThem.sh`. It performs the following steps:

1.  **Fetch PRs**: Uses the GitHub CLI (`gh`) to list pull requests from `obsidianmd/obsidian-releases`.
2.  **Filter & Extract**: Processes the PRs to extract repository URLs, removing duplicates and filtering for relevant labels.
3.  **Enrich Data**: For each repository found:
    - Fetches the list of files in the latest release.
    - Fetches and decodes the `manifest.json`.
4.  **Generate Lists**: outputs several JSON files serving different purposes:
    - `registry-index.json`: A lightweight list of PRs and repo URLs.
    - `registry-files.json`: Includes file lists for releases.
    - `registry-complete.json`: The full dataset including manifests.
    - `installable-plugins.json`: A filtered list of plugins that have a valid `manifest.json` and a `main.js`.
    - `installable-themes.json`: A filtered list of themes that have a valid `manifest.json` and a `theme.css`.

## Automation

A GitHub Actions workflow (`.github/workflows/update-registry.yml`) runs:

- **On Push**: Whenever changes are pushed to `main`.
- **Weekly**: Every Sunday at midnight.
- **Manually**: Can be triggered via the Actions tab.

The workflow generates the JSON files and deploys them, along with an `index.html`, to the `gh-pages` branch, making the registry accessible via GitHub Pages.

## Accessing the Data

The registry data is hosted on GitHub Pages. You can access the files at:

- `https://thejusticeman.github.io/obsidian-unofficial-plugins-page/installable-plugins.json`
- `https://thejusticeman.github.io/obsidian-unofficial-plugins-page/installable-themes.json`
- `https://thejusticeman.github.io/obsidian-unofficial-plugins-page/registry-complete.json`

## Local Usage

1.  Install dependencies:

    ```bash
    npm install
    ```

    _Note: You also need `gh` (GitHub CLI) and `jq` installed on your system._

2.  Run the script:
    ```bash
    ./getThem.sh
    ```
