#!/bin/bash

create_repo() {
  echo "Repo creation implementation goes here."
}

validate_repo() {
  echo "Validation implementation goes here."
}

submodule_repo() {
  echo "Submodule management implementation goes here."
}

repo_path="${1}"

if [ -z "$repo_path" ]; then
  repo_path="." 
fi

# repo_path="./testing/$repo_path" 

# touch "$repo_path/repo.log"
# rm -f "$repo_path/repo.log"

command="${2}"

echo "Repository Path: $repo_path"
echo "Command: $command"

case $command in
  create)
    create_repo "$repo_path"
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

