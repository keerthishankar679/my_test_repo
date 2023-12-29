#!/bin/bash
 
# change with <+steps.List_Files_Changed.output.outputVariables.FILES>
sample=$(git diff --name-only origin/main...HEAD)


echo "***************change file*************"
echo $sample
echo "***************************************"
echo ""
# Arrays to collect validation error_flag & pass_flag
declare -a error_flag
declare -a pass_flag
i=1
for file in $sample; do
    echo "***************************************"
    echo "${i}. $file "
    # Current dir of change file
    directory=$(dirname $file)
    # templateId=$(yq -r '.template.templateId' "$file")
 
    # Step to validate the existence of README.md file in the directory
    if [ ! -f "${directory}/README.md" ]; then    
        error_flag[0]=1
        #echo "Error: ${directory}/README.md file not found. Please include a README.md file in the directory before merging the pull request."
    else
        pass_flag[0]=1
    fi
    # Step to validate the existence of templateId.stable in the directory
    file_name=$(basename $file)
 
    if echo "$file_name"| grep -q ".stable" ; then
 
        templateId=$(echo "$file_name"|grep -i ".stable"| cut -d "." -f 1)
        if [ ! -f "${directory}/${templateId}.stable" ]; then
            echo "$templateId"
            #echo "Error: ${directory}/${templateId}.stable file not found. Please associate the file with the template before merging the pull request."
            error_flag[1]=1
        else
            #echo "stable found!"
            pass_flag[1]=1
        fi
 
    else
        templateId=" "
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
    
    let i=i+1
done
echo ""
echo "*****************Final result**************"
echo ""
if [ ${pass_flag[0]} -gt 0 ]; then
    echo "Readme found!"
fi
if [ ${pass_flag[1]} -gt 0 ]; then
    echo "Stable found!"
fi