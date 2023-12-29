#!/bin/bash
 
# Installing the yq
# apt-get install -y yq jo
 
# change with <+steps.List_Files_Changed.output.outputVariables.FILES>
sample=$(git diff --name-only origin/main...HEAD)
#identifier="Maven_Build_and_push_to_Nexus"
echo "***************change file are*************"
echo $sample
# Array to collect validation errors
declare -a errors
declare -a successfull
i=1
for file in $sample; do
    echo "***************************************"
    echo "${i}. $file "
    # Current dir of change file
    directory=$(dirname $file)
    # templateId=$(yq -r '.template.identifier' "$file")
 
    echo "current dir: $directory"
    echo "templateId: ${templateID}"
 
    # Step to validate the existence of README.md file in the directory
    if [ -f "${directory}/README.md" ]; then
        successfull[0]=1
    else
        errors[0]=1
    fi
    # Step to validate the existence of identifier.stable in the directory
    file_name=$(basename $file)
 
    if echo "$file_name"| grep -q ".stable" ; then
 
        identifier=$(echo "$file_name"|grep -i ".stable"| cut -d "." -f 1)
        echo "$identifier"
        echo "$directory"
       
        if [ ! -f "${directory}/${identifier}.stable" ]; then
            #echo "Error: ${directory}/${identifier}.stable file not found. Please associate the file with the template before merging the pull request."
            errors[1]=1
        else
            #echo "stable found!"
            successfull[1]=1
        fi
 
    else
        identifier=" "
    fi
    echo "value of identifier::$identifier:"
    let i=i+1
done
echo "*****************Final result**************"
if [ ${errors[0]} -gt 0 ]; then
    echo "Readme not found!"
fi
if [ ${successfull[1]} -gt 0 ]; then
    echo "Stable found!"
fi