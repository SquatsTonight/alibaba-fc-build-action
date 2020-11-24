#!/bin/bash
set -e

COMPILED_LANGUAGE_LIST=('java' 'dotnetcore')
INTERPRETED_LANGUAGE_LIST=('nodejs' 'python' 'php')

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# Parse template.yml file
template_file_path=""
if test -f "$INPUT_WORKING_DIRECTORY"/template.yml; then
  template_file_path="$INPUT_WORKING_DIRECTORY"/template.yml
elif test -f "$INPUT_WORKING_DIRECTORY"/template.yaml; then
  template_file_path="$INPUT_WORKING_DIRECTORY"/template.yaml
else
  echo "template.yml/template.yaml file dose not exists in $INPUT_WORKING_DIRECTORY."
  exit 1
fi

parsed_yml=$(parse_yaml "$template_file_path")

# Generate target projects
declare -a projects_list
if [ "$INPUT_PROJECTS" == "*" ]; then
  projects_list=( $( echo "$parsed_yml" | grep "Component" | sed 's/_Component=".*"//g' ) )
else
  projects_list=( $INPUT_PROJECTS )
fi

# build/install for every project
for project in "${projects_list[@]}"
do
  runtime=$( echo "$parsed_yml" | grep "$project" | grep "Runtime" | sed 's/'$project'_.*_Runtime=//g; s/\"//g' )
  runtime_prefix=$( echo "$runtime" | sed 's/[0-9]\+\(.[0-9]\+\)*//g' )
  echo "runtime_prefix: $runtime_prefix"
  code_uri=$( echo "$parsed_yml" | grep "$project" | grep "CodeUri" | sed 's/'$project'_.*CodeUri=//g; s/\"//g' )

  if [[ $COMPILED_LANGUAGE_LIST =~ (^|[[:space:]])$runtime_prefix($|[[:space:]]) ]]; then
    echo "Building artifacts for project $project with compiled runtime: $runtime..."
    (
      set -e
      cd "$INPUT_WORKING_DIRECTORY"
      sudo --preserve-env s "$project" build docker || { echo "build failed"; exit 1; }
    )
  elif [[ $INTERPRETED_LANGUAGE_LIST =~ (^|[[:space:]])$runtime_prefix($|[[:space:]]) ]]; then
    echo "Installing dependencies for project $project with interpreted runtime: $runtime..."
    ( 
      set -e
      cd "$INPUT_WORKING_DIRECTORY"
      sudo --preserve-env s "$project" install docker || { echo "build failed"; exit 1; }
    )
  else
    echo "Unsupported runtime: $runtime"
    exit 1
  fi
done