#!/bin/bash
 
#apt-get install -y yq jo

# Loop through the changed files in the pull request

while read -r changed_file; do
  # Check if the file is a YAML file

  if [[ "$changed_file" == *".yaml" ]]; then

    identifier=`yq -r '.template.identifier' "$changed_file"`

    # Extract the directory of the changed file

    directory=$(dirname "$changed_file")
	 
	if ! echo "$changed_file" | grep -q "${identifier}"; then
	
	  changed_file_name=$(basename "$changed_file")
	  
	  echo "Error: \"${changed_file_name}\" is not containing the matching identifier \"${identifier}\""
	  
	  exit 1
	  
	fi
	
  fi

done <<< "$(git diff --name-only origin/main...HEAD)"

echo "Validation passed, All YAML files in the directory are containing same identifier"