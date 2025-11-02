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

    # Adding submodules
    local submodules_added=()
    git config --global protocol.file.allow always
    local i=1
    while true; do
        read -p "Add submodule $i? (y/n): " add_choice
        if [[ "$add_choice" != "y" ]]; then
            break
        fi

        read -p "Enter local path for submodule $i: " submodule_path
        read -p "Enter source directory of submodule $i (e.g., ../external-module): " submodule_source
        
        if (echo "$submodule_path" | grep -q /); then
            echo "Error: Nested submodules ($submodule_path) are not allowed." >&2
            exit 1
        fi
        
        source_abs_path=$(readlink -f "$submodule_source")
        if [ ! -d "$source_abs_path" ] || ! git -C "$source_abs_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo "Error: Source $submodule_source is not a valid Git repository." >&2
            continue 
        fi

        git submodule add "file://$source_abs_path" "$submodule_path"
        echo "Added submodule $i: $submodule_source at $submodule_path"
        read -p "Enter specific revision (commit hash, branch, or tag) for submodule $i (leave empty for default): " submodule_revision
        if [ -n "$submodule_revision" ]; then
            (
            cd "$submodule_path" || exit 1
            git checkout "$submodule_revision"
        )
            echo "Checked out submodule $i to revision $submodule_revision"
        submodules_added+=("$submodule_path $submodule_revision")
        else
        submodules_added+=("$submodule_path default")
      fi
      i=$((i + 1)) 
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

