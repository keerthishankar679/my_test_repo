#!/bin/bash
 
# change with <+steps.List_Files_Changed.output.outputVariables.FILES>
sample=$(git diff --name-only origin/main...HEAD)


echo "***************changed_files************"
for file in $sample; do
    echo $file
done    
echo "****************************************"
echo ""
# Arrays to collect validation flag
declare -a flag

i=1

for file in $sample; do
    echo "***************************************"
    echo "${i}. $file "
    let i=i+1    
    # Current dir of change file
    directory=$(dirname $file)
    # templateId=$(yq -r '.template.templateId' "$file")
 
    # Step to validate the existence of README.md file in the directory
    if [ ! -f "${directory}/README.md" ]; then    
        flag[0]=1
        #echo "Error: ${directory}/README.md file not found. Please include a README.md file in the directory before merging the pull request."
    fi
    # Step to validate the existence of templateId.stable in the directory
    file_name=$(basename $file)
	echo "$file_name"
 
    if echo "$file_name"| grep -q ".stable" ; then
 
        templateId=$(echo "$file_name"|grep -i ".stable"| cut -d "." -f 1)

        if [ ! -f "${directory}/${templateId}.stable" ]; then
            echo "$templateId"
            #echo "Error: ${directory}/${templateId}.stable file not found. Please associate the file with the template before merging the pull request."
            flag[1]=1
        fi
 
    else
        templateId=""
    fi

    if [[ $file != *.yaml ]] || [[ $file == .harness/* ]]; then
        continue
    fi

    templateId=`yq -r '.template.identifier' "$file"`
    templateVersion=`yq -r '.template.versionLabel' "$file"`
    stableFile="${directory}/${templateId}.stable"
    stableVersion=`cat $stableFile`

    echo "templateId $templateId"
    echo "templateVersion $templateVersion"
    echo "stableVersion $stableVersion"

    if [[ "$file_name" == "${templateId}_${stableVersion}.yaml" ]]; then
    
	    echo "stable version is pointing to a valid version : $file_name"
	 
	    if echo "$file_name" | grep -q "${templateId}"; then
			echo "identifier is matching"
			flag[2]=1
		
	    fi
    
    fi	
    
done
echo ""
echo "*****************Final result**************"
echo ""
if [[ ${flag[0]} -gt 0 ]]; then
    echo "README.md not found!"	
else	
	echo "README.md found" 
fi
if [[ ${flag[1]} -gt 0 ]]; then
    echo "Stable not found!"
else	
	echo "Stable found" 
fi	

if [[ ${flag[2]} -gt 0 ]]; then

  echo "The stable version is pointing to a valid version"

else

  echo "The stable version is not pointing to a valid version"
  
fi