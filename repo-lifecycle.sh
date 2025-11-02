#!/bin/bash

repo_path="${1}"

if [ -z "$repo_path" ]; then
  repo_path="." 
fi

repo_path="./testing/$repo_path" # todo: remove this part after testing
cd "$repo_path" || exit 1


create_repo() {
    # Asking for repository name
    read -p "Enter repository name: " repo_name
    new_repo_path="$repo_path/$repo_name"
    echo repo_path="$new_repo_path"
    
    # Checking if the repository already exists
    
    if is_repo "$repo_name"; then
      echo "Repository already exists at $new_repo_path"
      return
    fi

    # Asking for custom main branch name
    read -p "Enter custom name for main branch (default: main): " main_branch
    if [ -z "$main_branch" ]; then
      main_branch="main"
    fi
    
    # Confirming repository creation
    read -p "Create new repository at $new_repo_path with branch $main_branch? (y/n): " choice
    if [[ "$choice" != "y" ]]; then
      echo "Repository creation aborted."
      return
    fi
    # Creating the repository
    git init -b "$main_branch" "$repo_name"
    cd "$repo_name" || exit 1
    git commit --allow-empty -m "Initial empty snapshot for $main_branch branch"
    echo "Initialized empty Git repository in $new_repo_path"
    
    # echo "Current directory after repo creation:"
    # pwd

    # Asking for submodules
    read -p "How many submodules would you like to add (up to 3)? (0 for none): " submodule_count
    if ! [[ "$submodule_count" =~ ^[0-3]$ ]]; then
      echo "Invalid number of submodules. Skipping submodule addition."
      return
    fi

    # Adding submodules
    git config --global protocol.file.allow always
    for (( i=1; i<=submodule_count; i++ )); do
      read -p "Enter local path to add submodule $i: " submodule_path
      read -p "Enter source directory of the submodule $i (relative to repository root): " submodule_source
      source_abs_path=$(readlink -f "$submodule_source")
      git submodule add "file://$source_abs_path" "$submodule_path"
      echo "Added submodule $i: $submodule_source at $submodule_path"
      read -p "Enter specific revision (commit hash, branch, or tag) for submodule $i (leave empty for default): " submodule_revision
      if [ -n "$submodule_revision" ]; then
        cd "$submodule_path" || exit 1
        git checkout "$submodule_revision"
        cd - || exit 1
        echo "Checked out submodule $i to revision $submodule_revision"
      fi
    done
    git config --global --unset protocol.file.allow


}

validate_repo() {
  echo "Validation implementation goes here."
}

submodule_repo() {
  echo "Submodule management implementation goes here."
}

# shellcheck disable=SC2120
is_repo() {
  if [ -z "$1" ]; then
    path_to_check="."
  else 
    path_to_check="$1"
  fi

  if [ -d "./$path_to_check/.git" ]; then
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
      create)
        create_repo 
        ;;
      validate)
        validate_repo
        ;;
      submodule)
        submodule_repo
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

