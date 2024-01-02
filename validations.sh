#!/bin/bash
 
# change with <+steps.List_Files_Changed.output.outputVariables.FILES>
sample="stages/java/Build_and_push_to_Nexus/Maven_Build_and_push_to_Nexus.stable"

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
    if [ -f "${directory}/README.md" ]; then  
        flag[0]=1
    else
        flag[0]=0
        #echo "Error: ${directory}/README.md file not found. Please include a README.md file in the directory before merging the pull request."    
    fi
    # Step to validate the existence of templateId.stable in the directory
    file_name=$(basename $file)
    templateId=$(echo "$file_name"| grep -i ".stable"| cut -d "." -f 1)
    stable_templateId=$(echo "$file_name"| grep -i ".stable"| cut -d "." -f 1)
    if echo "$file_name"| grep -q ".stable" && [ -f "${directory}/${templateId}.stable" ] ; then
        flag[1]=1
        echo ${templateId}
        #if [ ! -f "${directory}/${templateId}.stable" ]; then
        #    echo "$templateId"
        #    #echo "Error: ${directory}/${templateId}.stable file not found. Please associate the file with the template before merging the pull request."
        #    
        #fi
    else
        echo "else hi error"
        flag[1]=0         
    fi    

    if [[ $file != *.yaml ]] || [[ $file == .harness/* ]]; then
        continue
    fi

    templateId=`yq -r '.template.identifier' "$file"`
    templateVersion=`yq -r '.template.versionLabel' "$file"`
    templateType=$(yq -r '.template.type' "$file")
    stableFile="${directory}/${templateId}.stable"
    stableVersion=`cat $stableFile`
    top_level_directory=$(dirname $file| grep -iE "stage|step|pipeline"| cut -d '/' -f 1 )

    echo "templateId : $templateId"
    echo "templateVersion : $templateVersion"
    echo "stableVersion : $stableVersion"
    echo "templateType : $templateType"
    echo "top_level_directory : $top_level_directory"
    echo "stable_templateId : $stable_templateId"

    if [[ "$file_name" == "${templateId}_${stableVersion}.yaml" ]]; then
	    echo "stable version is pointing to a valid version : $file_name"
		flag[2]=1
    else
        flag[2]=0
    fi	

	if ! echo "$file_name" | grep -q "${stable_templateId}"; then
	    flag[3]=1
	    echo "Error: \"${file_name}\" is not containing the matching identifier \"${stable_templateId}\""  
	else
        flag[3]=0
    fi

    if [ "$top_level_directory" != "${templateType,,}s" ]; then
        flag[4]=1
    else
        flag[4]=0
    fi    

done

echo ""
echo "*****************Final result**************"
echo ""

echo ${flag[@]}
if [[ "${flag[0]}" -gt 0 ]]; then
    echo "README.md found!"	
else	
	echo "README.md not found" 
fi
if [[ "${flag[1]}" -gt 0 ]]; then
    echo ".stable file found!"
else	
	echo ".stable file not found" 
fi	
if [[ "${flag[2]}" -gt 0 ]]; then

  echo "The stable version is pointing to a valid version"

else

  echo "The stable version is not pointing to a valid version"
  
fi
if [[ "${flag[3]}" -gt 0 ]]; then
    echo "Error: file is not containing the matching identifier \"${stable_templateId}\""
else
    echo "Idenfier is matching"
fi
if [[ "${flag[4]}" -gt 0 ]]; then
    echo "Error: Template type is not matching the top level directory"
else
    echo "All templates in top level directory is matching its type"    
fi 
flag=()
echo ${flag[@]}  