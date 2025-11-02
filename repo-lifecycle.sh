#!/bin/bash

repo_path="${1}"

if [ -z "$repo_path" ]; then
  repo_path="." 
fi

repo_path=$(readlink -f "$repo_path") 
cd "$repo_path" || exit 1


create_repo() {
    read -p "Enter project name (PNAME): " PNAME
    if [ -z "$PNAME" ]; then
        echo "Error: PNAME cannot be empty." >&2
        return
    fi
    new_repo_path="$repo_path/$PNAME"
    # echo repo_path="$new_repo_path"
    
    if [ -d "$new_repo_path" ] && [ "$(ls -A "$new_repo_path")" ]; then
        echo "Error: Path $repo_path exists and is not empty." >&2
        return
    fi

    read -p "Enter custom name for main branch (default: main): " main_branch
    if [ -z "$main_branch" ]; then
      main_branch="main"
    fi
    
    read -p "Create new repository at $new_repo_path with branch $main_branch? (y/n): " choice
    if [[ "$choice" != "y" ]]; then
      echo "Repository creation aborted."
      return
    fi

    git init -b "$main_branch" "$PNAME"
    cd "$PNAME" || exit 1
    git commit --allow-empty -m "Initial empty snapshot for $PNAME"
    echo "Initialized empty Git repository in $new_repo_path"
    
    # echo "Current directory after repo creation:"
    # pwd

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

    repo_path="$new_repo_path"
    echo "Repository created at $repo_path"
}

validate_repo() {
  echo "Validation implementation goes here."
}

submodule_repo() {
    cd "$repo_path" || exit 1
    if ! is_repo; then
        echo "Not a Git repository!" >&2
        exit 1
    fi

    nested=0
    git submodule foreach --quiet 'if [ -f .gitmodules ]; then exit 1; fi' || nested=1
    if [ $nested -eq 1 ]; then
        echo "Error: Nested submodules detected." >&2
        exit 1
    fi

    submodules=$(git submodule status | awk '{print $2}')
    if [ -z "$submodules" ]; then
        echo "No submodules found."
        return
    fi

    echo "Submodules:"

    git submodule status | while read -r line; do
        path=$(echo "$line" | awk '{print $2}')
        sha_and_status=$(echo "$line" | awk '{print $1}')

        if [[ "$sha_and_status" == -* ]]; then
            status_desc="Not initialized"
        elif [[ "$sha_and_status" == +* ]]; then
            status_desc="New commits (needs parent update)"
        else
            if ! git -C "$path" diff-index --quiet HEAD --; then
                status_desc="Uncommitted changes in worktree"
            else
                status_desc="Clean"
            fi
        fi
        
        printf "%-30s %s\n" "$path" "$status_desc"
    done
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

# echo "Repository Path: $repo_path"
# echo "Command: $command"

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

