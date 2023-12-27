#!/bin/bash
 
# Get the identifier from the pipeline YAML file

identifier="Maven_Build_and_push_to_Nexus" 

# Function to get the stable version

stable_version() {

  local directory="$1"
 

  if [ -s "${directory}/${identifier}.stable" ]; then

    #echo "${directory}/${identifier}.stable file is not empty."
	
	  stable_version=$(cat ${directory}/${identifier}.stable)

	
  else
  
    echo "error .stable file is empty"

	  exit 1  
	
  fi

} 

# Print the output of git diff

#echo "Changed files in the pull request:"

#git diff --name-only origin/main...HEAD

# Loop through the changed files in the pull request
flag=0

while read -r changed_file; do
  # Check if the file is a YAML file

  if [[ "$changed_file" == *".yaml" ]]; then

    # Extract the directory of the changed file

    directory=$(dirname "$changed_file")

	  # Function to get the stable version
    
    stable_version "$directory"

    #echo "$changed_file"

    if [[ "$changed_file" == "${directory}/${identifier}_${stable_version}.yaml" ]]; then
    
	    #echo "stable version is pointing to a valid version : $changed_file"
	 
	    if echo "$changed_file" | grep -q "${identifier}"; then
	  
        echo "Identifier: $identifier"
        echo "Stable version: $stable_version"
	      echo "identifier is matching"
        version_label=$stable_version
        let flag=flag+1 
		
	    fi
    
    fi

  fi

done <<< "$(git diff --name-only origin/main...HEAD)"

if [[ $flag -eq 1 ]]; then

  echo "Version Label: $version_label"
  echo "The stable version is pointing to a valid version"

else

  echo "The stable version is not pointing to a valid version"
  exit 1

fi