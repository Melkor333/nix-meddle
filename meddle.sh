#!/usr/bin/env osh

MEDDLE_PATH="${HOME}/.local/share/meddle"
NIX_STORE_PATH=/nix/store

# COMAND DEFINITIONS
# ------------------
COPY_COMMAND="rsync --mkpath -aAX"

_date() {
    date +%s
}
DATE=$(_date)

_err() {
    echo "$@" 1>&2
}

_ask() {
    gum confirm "$@"
    return $?
}

# If NO_MEDDLE is set, only echo commands
_run() {
    if [[ -z "$NO_MEDDLE" ]]; then
        "$@"
    else
        echo not running "$@"
    fi
}

get_meddle_path() {
    echo "${MEDDLE_PATH}/${DATE}_$directory"
}

# UI to get one element from list
_filter() {
    # TODO: Test if 'gum' is installed and use something else otherwise
    gum filter
}

find_meddle_paths() {
# Check if (and how many) paths already exist for a partial directory name
    local count=0
    # TODO: ignore files, only take folders
    for file in $(ls "${MEDDLE_PATH}/" | grep "$@"); do
        echo "$file"
        count=$((count+1))
    done
    return "$count"
}

copy_path() {
    _run $COPY_COMMAND "${1}/" "$2"
}

# Make a whole directory writable
make_writable() {
    _run chmod -R u+w "$1"
}

# Check if a mountpoint already exist
# Return true if it does exist
check_mountpoint() {
    cat /proc/self/mountinfo | awk '{ print $5 }' | grep -q "$@"
    return $?
}

# Get all paths from $PATH
get_path_dirs() {
    echo $PATH | tr ':' '\n' | grep '^/nix/store' | _filter
}

# get all existing paths in /nix/store
get_all_nix_dirs() {
    find /nix/store/ -maxdepth 1 -type d | awk -F'/' '{print $NF }' | _filter
}

# TODO: Detect if we're already unshared
unshare_mount() {
    if [[ "$(id -u)" -gt 0 ]]; then
        _run unshare -r -m
    fi
}

# Mount an existing path
mount_path() {
    unshare_mount
    _run mount --bind "$1" "$2"
}

meddle() {
    # Used for creating a new copy
    DATE=$(_date)
    directory=$(get_all_nix_dirs)
    if [[ -z "$directory" ]]; then
       _err "no directory chosen. exiting"
       exit 1
    fi
    dirs=$(find_meddle_paths "$directory")
    dir_count=$?
    if [[ "$dir_count" -gt 0 ]] && _ask "directory already exists $dir_count times. should one of them be used?:  $dirs"; then
        if [[ "$dir_count" -gt 1 ]]; then
           directory=$(echo "$dirs" | _filter)
        else
            directory="$dirs"
        fi
        meddle_path="${MEDDLE_PATH}/${directory}"
        nix_path="${NIX_STORE_PATH}/${directory#*_}" # Cut away DATE_ from directory
    else
        if ! _ask "Directory doesn't exist yet, create?"; then
            return 1
        fi
        echo "creating dir!"
        meddle_path="$(get_meddle_path ${directory})"
        nix_path="${NIX_STORE_PATH}/${directory}"
        copy_path "$nix_path" "$meddle_path"
        make_writable "$meddle_path"
    fi
    mount_path "$meddle_path" "$nix_path"
}
