#!/bin/bash
 
# Get the identifier from the pipeline YAML file

identifier="Maven_Build_and_push_to_Nexus" 


# Loop through the changed files in the pull request

while read -r changed_file; do
  # Check if the file is a YAML file

  if [[ "$changed_file" == *".yaml" ]]; then

    # Extract the directory of the changed file

    directory=$(dirname "$changed_file")

	  # Function to get the stable version
	 
	if echo "$changed_file" | grep -v "${identifier}"; then
	
      echo "Identifier: $identifier"
	  echo "identifier is not matching"
      version_label=$stable_version
	  
	fi
	
  fi

done <<< "$(git diff --name-only origin/main...HEAD)"