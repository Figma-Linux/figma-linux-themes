#!/bin/bash

pull_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
files=$(gh pr -R Figma-Linux/figma-linux-themes view ${pull_number} --json files -q '.files[].path')

echo "${files}" | while read -r file
do
    if [[ "$file" =~ \.json$ ]]; then
      content="$(gh api "repos/Figma-Linux/figma-linux-themes/contents/${file}?ref=test-ci" -q '.content' | base64 -d)"
      themeName="$(echo "$content" | jq '.name' | tr -d '\"')"
      themeAutor="$(echo "$content" | jq '.author' | tr -d '\"')"

      if [[ -z "${themeName}" ]]; then
        echo "Invalid theme name";
        exit -1
      fi
      if [[ "${themeName}" == "Default Theme" ]]; then
        echo "Invalid theme name";
        exit -1
      fi
      if [[ -z "${themeAutor}" ]]; then
        echo "Invalid theme author name";
        exit -1
      fi
      if [[ "${themeAutor}" == "Figma" ]]; then
        echo "Invalid theme author name";
        exit -1
      fi
    fi
done

gh pr -R Figma-Linux/figma-linux-themes merge ${pull_number}
