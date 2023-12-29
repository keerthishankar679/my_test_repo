#!/bin/bash
 
changefile=$(git diff --name-only origin/main...HEAD)
echo "All Change Files:: $changefile"
# what about readme.md and stable file
my_file="Maven_Build_and_push_to_Nexus.stable"
directory=$(dirname $my_file )    
echo "directory is   $directory"
i=1
flag=0
for file in $changefile; do
    if [[ $file != *.yaml ]] || [[ $file == .harness/* ]]; then
        continue
    fi
    echo "**********change yaml=*******************"
    echo "$i: $file"
    directory=$(dirname $file)
    echo "directory ---- $directory"
    top_level_directory=$(dirname $file| grep -iE "stage|step|pipeline"| cut -d '/' -f 1 )
    echo "Top_level_directory only yaml: $top_level_directory"
    template_type=$(yq -r '.template.type' "$file")
    if [ $top_level_directory != $template_type ]; then
        let flag=flag+1
    fi
   
    echo "template_type: $template_type"
    echo "********************************************************"
    let i=i+1
done
echo "Value of Flag:: $flag"
if [ $flag -gt 0 ]; then
    echo "Error1: Template is not in the top level directory matching its type"
else
    echo "All template is in top level directory maching its type"
fi