gh pr list \
  --repo obsidianmd/obsidian-releases \
  --json number,labels,createdAt,body,id \
  --jq 'map({number, createdAt, labels: .labels | map(.name), repo: (.body | [scan("https?://github\\.com/[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+")] | map(select(contains("obsidian-releases") | not)) | first | if . then sub("https?://github\\.com/"; "") else null end)})' \
  --limit 10000 > registry-index.json

# Add a field with a list of the files in the latest release for each repository
# We use a loop because standard jq cannot execute shell commands
tmp=$(mktemp)
tmp_files=$(mktemp)
jq -c '.[]' registry-index.json | while read -r item; do
  repo=$(echo "$item" | jq -r '.repo')
  files=$(gh release view --repo "$repo" --json assets --jq ".assets | map(.name)" 2> /dev/null || echo "[]")

  # Check if files is empty or null, default to empty array
  if [ -z "$files" ] || [ "$files" == "null" ]; then files="[]"; fi

  # Get the manifest
  repo_slug=$(echo "$repo" | sed -E 's|https?://github.com/||')
  # remove trailing .git if present
  repo_slug=${repo_slug%.git}
  manifest=$(gh api "repos/$repo_slug/contents/manifest.json" --jq ".content" 2> /dev/null | base64 -d 2> /dev/null)

  # Check if manifest is valid JSON, default to null
  if [ -z "$manifest" ] || ! echo "$manifest" | jq empty > /dev/null 2>&1; then
    manifest="null"
  fi

  echo "$item" | jq --argjson f "$files" '. + {files: $f}' >> "$tmp_files"
  echo "$item" | jq --argjson f "$files" --argjson m "$manifest" '. + {files: $f, manifest: $m}' >> "$tmp"

  echo "Processed $repo with files: $files"
done
jq -s '.' "$tmp_files" > registry-files.json
jq -s '.' "$tmp" > registry-complete.json
rm "$tmp" "$tmp_files"

# write installable-plugins.json with only plugins that have a manifest and a main.js file
jq '[.[] | select(.manifest != null and (.files | index("main.js") != null))]' registry-complete.json > installable-plugins.json

# write installable-themes.json with only themes that have a manifest and a theme.css file
jq '[.[] | select(.manifest != null and (.files | index("theme.css") != null))]' registry-complete.json > installable-themes.json

# Format the JSON file for better readability
# npm run format
