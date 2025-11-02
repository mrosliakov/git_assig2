#!/bin/bash

repo_path="${1}"

if [ -z "$repo_path" ]; then
  repo_path="." 
fi

repo_path="./testing/$repo_path" # todo: remove this part after testing
mkdir -p "$repo_path/test"

create_repo() {
    read -p "Enter repository name: " repo_name
    new_repo_path="$repo_path/$repo_name"
    echo repo_path="$new_repo_path"
    
    #if is_repo "$repo_name"; then 
    if is_repo "$new_repo_path"; then
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
  if [ -z "$1" ]; then
    path_to_check="$repo_path"
  else 
    path_to_check="$1"
  fi

  if [ -d "$path_to_check/.git" ]; then
    return 0
  else
    return 1
  fi
}

command="${2}"

echo "Repository Path: $repo_path"
echo "Command: $command"

if [ -z "$command" ]; then
  while true; do
    read -p "Enter command (create, validate, submodule, exit): " command
    case $command in
      create|validate|submodule)
        ;;
      exit)
        echo "Exiting."
        exit 0
        ;;
      *)
        echo "Invalid command. Please try again."
        continue
        ;;
    esac

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
    esac
  done
fi

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
    echo "Invalid command. Use create, validate, submodule or no command for interactive mode."
    ;;
esac

echo "Done."

