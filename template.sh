#!/bin/bash
 
# Get the identifier from the pipeline YAML file

identifier="Maven_Build_and_push_to_Nexus" 

# Function to get the stable version

stable_version() {

  local directory="$1"
 

  if [ -s "${directory}/${identifier}.stable" ]; then

    echo "${directory}/${identifier}.stable file is not empty."
	
	stable_version=$(cat ${directory}/${identifier}.stable)
	
	echo $stable_version
	
  else
  
    echo "error .stable file is empty"
    
	exit 1  
	
  fi

} 

# Print the output of git diff

echo "Changed files in the pull request:"

git diff --name-only origin/main...HEAD

# Loop through the changed files in the pull request

while read -r changed_file; do

  # Check if the file is a YAML file

  if [[ "$changed_file" == *".yaml" ]]; then

    # Extract the directory of the changed file

    directory=$(dirname "$changed_file")

	# Function to get the stable version
    
    stable_version "$directory"
	
	if [[ "${directory}/${identifier}_${stable_version}.yaml" == "$changed_file" ]]; then
	
	  echo "stable version is correct"
	 
	  if echo "$changed_file" | grep -q "${identifier}"; then
	  
	    echo "identifier is matching" 
		
	  fi

  fi
##
done <<< "$(git diff --name-only origin/main...HEAD)"