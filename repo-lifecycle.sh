#!/bin/bash

repo_path="${1}"

if [ -z "$repo_path" ]; then
  repo_path="." 
fi

repo_path="./testing/$repo_path" # todo: remove this part after testing
mkdir -p "$repo_path/test"

create_repo() {
    read -p "Enter repository name: " repo_name
    repo_path="$repo_path/$repo_name"
    echo repo_path="$repo_path"
    
    #if is_repo "$repo_name"; then 
    if is_repo; then
      echo "Repository already exists at $repo_path"
    else
      read -p "Create new repository at $repo_path? (y/n): " choice
        if [[ "$choice" != "y" ]]; then
            echo "Repository creation aborted."
            return
        fi
      git init -b main "$repo_path"
      cd "$repo_path" || exit
      git commit --allow-empty -m "Initial commit"
      echo "Initialized empty Git repository in $repo_path"
    fi
    
}

validate_repo() {
  echo "Validation implementation goes here."
}

submodule_repo() {
  echo "Submodule management implementation goes here."
}

is_repo() {
  #repo_to_check="$1"
  if [ -d "$repo_path/.git" ]; then
    return 0
  else
    return 1
  fi
}

command="${2}"

echo "Repository Path: $repo_path"
echo "Command: $command"

case $command in
  create)
    create_repo 
    ;;
  validate)
    validate_repo
    ;;
  submodule)
    submodule_repo
    ;;
  *)
    echo "While loop goes here."
    ;;
esac

echo "Done."

