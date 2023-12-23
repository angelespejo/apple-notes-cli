#!/bin/bash

# #############################################################################
# MANAGE APPLE NOTES
# #############################################################################
#
# @description Manage Apple Notes.app via cli
# @author Angelo<angelo@pigeonposse.com>
# @version 1.0.0
#
# #############################################################################

# #############################################################################
# VARS
# #############################################################################
NAME="apple-notes"
VERSION="1.0.0"
TYPE_SUCCESS="succes"
TYPE_ERROR_NONE_PARAMS="error-none-params"
TYPE_ERROR_NONE_NOTE="error-none-note"
TYPE_ERROR_NONE_FOLDER="error-none-folder"
TYPE_ERROR_NONE_CHILD_FOLDER="error-none-child-folder"
TYPE_ERROR_EXISTS_NOTE="error-exists-note"
TYPE_ERROR_EXISTS_FOLDER="error-exists-folder"
TYPE_ERROR_EXISTS_CHILD_FOLDER="error-exists-child-folder"
KEY=$1

# #############################################################################
# CLI DATA
# #############################################################################

function set_help() {
echo "Manage Apple Notes via CLI

Instructions:

    --help, -h ------------------------- Show help 
    --version, -v ---------------------- Show version

    open ------------------------------- Open app
    open {note} ------------------------ Open specific note name
    open-new  -------------------------- Open and create a new note

    add {note} ------------------------- Add note 
    add {parent} {note} ---------------- Add note in folder 
    add {parent} child} {note} --------- Add note in child folder 

    rm {note} -------------------------- Remove note 
    rm {parent} {note} ----------------- Remove note in folder 
    rm {parent} child} {note} ---------- Remove note in child folder 

    exists {note} ---------------------- Exists note 
    exists {parent} {note} ------------- Exists note in folder 
    exists {parent} child} {note} ------ Exists note in child folder 

    add-folder {parent} ---------------- Add folder 
    add-folder {parent} child} --------- Add child folder 

    rm-folder {parent} ----------------- Remove folder 
    rm-folder {parent} {child} --------- Remove child folder 
    rm-folder {parent} --only-notes ---- Remove only notes folder
    
    exists-folder {parent} ------------- Exists note in folder 
    exists-folder {parent} child} ------ Exists note in child folder 


version $VERSION
"
}

function set_version() {
    echo "$NAME v$VERSION"
}

# #############################################################################
# SHARED FUNCTIONS
# #############################################################################
function param_exists() {
    
    local string_to_find="$1"
    shift  # Para omitir el primer argumento, que es el string a buscar

    for arg in "$@"; do
        if [[ "$arg" == "$string_to_find" ]]; then
            return 0  
        fi
    done

    return 1 

}
function set_result(){
    local result="$@"
    if [ "${result:0:5}" = "error" ]; then
        echo "$result"
        return 1 
    else 
        echo "$result"
    fi
}

# #############################################################################
# OPEN
# #############################################################################
function open_note() {

    NOTE="$1"

    if [ -n "$NOTE" ]; then

        result=$(osascript -e "try
            tell application \"Notes\"
                set noteList to notes whose name contains \"$NOTE\"
                if (count of noteList) > 0 then
                    show (first item of noteList)
                    activate
                    return \"$TYPE_SUCCESS\"
                else
                    return \"$TYPE_ERROR_NONE_NOYE\"
                end if
            end tell
        end try")

        set_result $result

    else

        result=$(osascript -e "try
            tell application \"Notes\"
                show (first item of notes)
                activate
            end tell
        end try")
        set_result $result
    fi

}

function open_new_note() {
    
    result=$(osascript -e "try
        tell application \"Notes\"
            make new note
            show (first item of notes)
        end tell
    end try")

   set_result $result
}

# #############################################################################
# FOLDER
# #############################################################################
function remove_folder() {

    FOLDER="$1"
    CHILD_FOLDER="$2"

    if param_exists "--only-notes" "$@"; then
        DELETE_TYPE="only-notes"
    else 
        DELETE_TYPE="all"
    fi

    if [ -n "$FOLDER" ] && [ -n "$CHILD_FOLDER" ] && [[ "$CHILD_FOLDER" != "--only-notes" ]]; then
        result=$(osascript -e "try
            tell application \"Notes\"
                set parentFolder to \"$FOLDER\"
                set childFolder to \"$CHILD_FOLDER\"
                set deleteType to \"$DELETE_TYPE\"
                if (exists folder parentFolder) then
                    if (exists folder childFolder of folder parentFolder) then
                        if deleteType is equal to \"only-notes\" then
                            if exists notes of folder childFolder then
                                delete notes of folder childFolder
                            end if
                        else
                            delete folder childFolder
                        end if
                        return \"$TYPE_SUCCESS\"
                    else
                        return \"$TYPE_ERROR_NONE_CHILD_FOLDER\"
                    end if
                else
                    return \"$TYPE_ERROR_NONE_FOLDER\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$FOLDER" ]; then

        result=$(osascript -e "try
            tell application \"Notes\"
                set parentFolder to \"$FOLDER\"
                set deleteType to \"$DELETE_TYPE\"
                if (exists folder parentFolder) then
                    if deleteType is equal to \"only-notes\" then
                        if exists notes of folder parentFolder then
                            delete notes of folder parentFolder
                        end if
                    else
                        delete folder parentFolder
                    end if
                    return \"$TYPE_SUCCES\"
                else
                    return \"$TYPE_ERROR_NONE_FOLDER\"
                end if
            end tell
        end try")

        set_result $result

    else
        echo "$TYPE_ERROR_NONE_PARAMS"
        return 1 
    fi

}

function add_folder() {
    
    FOLDER="$1"
    CHILD_FOLDER="$2"
    
    if [ -n "$FOLDER" ] && [ -n "$CHILD_FOLDER" ]; then
        
        result=$(osascript -e "try
            tell application \"Notes\"
                set parentFolderName to \"$FOLDER\"
                set childFolderName to \"$CHILD_FOLDER\"
                
                if (exists folder parentFolderName) then
                    if (exists folder childFolderName of folder parentFolderName) then
                        return \"$TYPE_ERROR_EXISTS_FOLDER\"
                    else
                        make new folder at folder parentFolderName with properties {name:childFolderName}
                        return \"$TYPE_SUCCESS\"
                    end if
                else
                    make new folder with properties {name:parentFolderName}
                    make new folder at folder parentFolderName with properties {name:childFolderName}
                    return \"$TYPE_SUCCESS\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$FOLDER" ]; then
        
        result=$(osascript -e "try
            tell application \"Notes\"
                set parentFolderName to \"$FOLDER\"
                if (exists folder parentFolderName) then
                    return \"$TYPE_ERROR_EXISTS_FOLDER\"
                else
                    make new folder with properties {name:parentFolderName}
                    return \"$TYPE_SUCCESS\"
                end if
            end tell
        end try")

        set_result $result

    else
        echo "$TYPE_ERROR_NONE_PARAMS"
        return 1 
    fi

}

function exists_folder() {
    
    FOLDER="$1"
    CHILD_FOLDER="$2"
    
    if [ -n "$FOLDER" ] && [ -n "$CHILD_FOLDER" ]; then
        
        result=$(osascript -e "try
            tell application \"Notes\"
                set parentFolderName to \"$FOLDER\"
                set childFolderName to \"$CHILD_FOLDER\"
                if (exists folder parentFolderName) then
                    if not (exists folder childFolderName of folder parentFolderName) then
                        return \"$TYPE_ERROR_EXISTS_FOLDER\"
                    else
                        return \"$TYPE_SUCCESS\"
                    end if
                else
                    return \"$TYPE_SUCCESS\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$FOLDER" ]; then
        
        result=$(osascript -e "try
            tell application \"Notes\"
                set parentFolderName to \"$FOLDER\"
                if not (exists folder parentFolderName) then
                    return \"$TYPE_ERROR_EXISTS_FOLDER\"
                else
                    return \"$TYPE_SUCCESS\"
                end if
            end tell
        end try")

        set_result $result

    else
        echo "$TYPE_ERROR_NONE_PARAMS"
        return 1 
    fi

}

# #############################################################################
# NOTE
# #############################################################################
function remove_note() {

    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
        
        FOLDER="$1"
        CHILD_FOLDER="$2"
        NOTE="$3"

        result=$(osascript -e "try
            tell application \"Notes\"
                set theFolder to \"$FOLDER\"
                set theChildFolder to \"$CHILD_FOLDER\"
                set theNote to \"$NOTE\" 
                if (exists folder theFolder) then
                    if (exists folder theChildFolder of folder theFolder) then
                        if not (exists note named theNote of folder theChildFolder in folder theFolder) then
                            return \"$TYPE_ERROR_NONE_NOTE\"
                        else 
                            delete first note of folder theChildFolder in folder theFolder whose name is theNote
                            return \"$TYPE_SUCCESS\"
                        end if
                    else
                        return \"$TYPE_ERROR_NONE_CHILD_FOLDER\"
                    end if 
                else 
                    return \"$TYPE_ERROR_NONE_FOLDER\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$1" ] && [ -n "$2" ]; then
        
        FOLDER="$1"
        NOTE="$2"

        result=$(osascript -e "try
            tell application \"Notes\"
                set theFolder to \"$FOLDER\"
                set theNote to \"$NOTE\" 
                if (exists folder theFolder) then
                    if not (exists note named theNote in folder theFolder) then
                        return \"$TYPE_ERROR_NONE_NOTE\"
                    else 
                        delete first note in folder theFolder whose name is theNote
                        return \"$TYPE_SUCCESS\"
                    end if
                else 
                    return \"$TYPE_ERROR_NONE_FOLDER\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$1" ]; then

        NOTE="$1"
        result=$(osascript -e "try
            tell application \"Notes\"
                set theNote to first note whose name is \"$NOTE\"
                if exists theNote then
                    delete theNote
                    return \"$TYPE_SUCCESS\"
                else
                    return \"$TYPE_ERROR_NONE_NOTE\"
                end if
            end tell
        end try")

        set_result $result

    else
        echo "$TYPE_ERROR_NONE_PARAMS"
        return 1 
    fi

}

function add_note() {
        
    make_folder="make new folder with properties {name:theFolder}"
    make_child_folder="make new folder at folder theFolder with properties {name:theChildFolder}"
    make_child_note="make new note of folder theChildFolder in folder theFolder with properties {name:theNote}"
    make_note="make new note at folder theFolder with properties {name:theNote}"
    
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
        
        FOLDER="$1"
        CHILD_FOLDER="$2"
        NOTE="$3"

        result=$(osascript -e "try
            tell application \"Notes\"
                set theFolder to \"$FOLDER\"
                set theChildFolder to \"$CHILD_FOLDER\"
                set theNote to \"$NOTE\" 
                if (exists folder theFolder) then
                    if (exists folder theChildFolder of folder theFolder) then
                        if (exists note named theNote of folder theChildFolder in folder theFolder) then
                            return \"$TYPE_ERROR_EXISTS_NOTE\"
                        else 
                            $make_child_note
                            return \"$TYPE_SUCCESS\"
                        end if
                    else
                        $make_child_folder
                        $make_child_note
                        return \"$TYPE_SUCCESS\"
                    end if 
                else 
                    $make_folder
                    $make_child_folder
                    $make_child_note
                    return \"$TYPE_SUCCESS\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$1" ] && [ -n "$2" ]; then
        
        FOLDER="$1"
        NOTE="$2"

        result=$(osascript -e "try
            tell application \"Notes\"
                set theFolder to \"$FOLDER\"
                set theNote to \"$NOTE\" 
                if (exists folder theFolder) then
                    if not (exists note named theNote in folder theFolder) then
				        $make_note
                        return \"$TYPE_SUCCESS\"
                    else 
                        return \"$TYPE_ERROR_EXISTS_NOTE\"
                    end if
                else 
                    $make_folder
                    $make_note
                    return \"$TYPE_SUCCESS\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$1" ]; then

        NOTE="$1"
        result=$(osascript -e "try
            tell application \"Notes\"
                set theNote to \"$NOTE\"
                if not (exists note named theNote) then
                    make new note with properties {name:theNote}
                    return \"$TYPE_SUCCESS\"
                else
                    return \"$TYPE_ERROR_EXISTS_NOTE\"
                end if
            end tell
        end try")

        set_result $result

    else
        echo "$TYPE_ERROR_NONE_PARAMS"
        return 1 
    fi

}

function exists_note() {
        
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
        
        FOLDER="$1"
        CHILD_FOLDER="$2"
        NOTE="$3"

        result=$(osascript -e "try
            tell application \"Notes\"
                set theFolder to \"$FOLDER\"
                set theChildFolder to \"$CHILD_FOLDER\"
                set theNote to \"$NOTE\" 
                if (exists folder theFolder) then
                    if (exists folder theChildFolder of folder theFolder) then
                        if not (exists note named theNote of folder theChildFolder in folder theFolder) then
                            return \"$TYPE_ERROR_EXISTS_NOTE\"
                        else 
                            return \"$TYPE_SUCCESS\"
                        end if
                    else

                        return \"$TYPE_SUCCESS\"
                    end if 
                else 
                    return \"$TYPE_SUCCESS\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$1" ] && [ -n "$2" ]; then
        
        FOLDER="$1"
        NOTE="$2"

        result=$(osascript -e "try
            tell application \"Notes\"
                set theFolder to \"$FOLDER\"
                set theNote to \"$NOTE\" 
                if (exists folder theFolder) then
                    if (exists note named theNote in folder theFolder) then
                        return \"$TYPE_SUCCESS\"
                    else 
                        return \"$TYPE_ERROR_EXISTS_NOTE\"
                    end if
                else 
                    return \"$TYPE_SUCCESS\"
                end if
            end tell
        end try")

        set_result $result

    elif [ -n "$1" ]; then

        NOTE="$1"
        result=$(osascript -e "try
            tell application \"Notes\"
                set theNote to \"$NOTE\"
                if (exists note named theNote) then
                    return \"$TYPE_SUCCESS\"
                else
                    return \"$TYPE_ERROR_EXISTS_NOTE\"
                end if
            end tell
        end try")

        set_result $result

    else
        echo "$TYPE_ERROR_NONE_PARAMS"
        return 1 
    fi

}

# #############################################################################
# EXECUTION
# #############################################################################

function main() {

    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "error-not-macos"
        return 1
    fi

    if param_exists "--help" "$@" || param_exists "-h" "$@"; then
        set_help
        return 0
    elif param_exists "--version" "$@" || param_exists "-v" "$@"; then
        set_version
        return 0
    elif [ "$KEY" = "open" ]; then
        open_note "${@:2}"
        return 0
    elif [ "$KEY" = "open-new" ]; then
        open_new_note 
        return 0
    elif [ "$KEY" = "rm-folder" ]; then
        remove_folder "${@:2}"
        return 0
    elif [ "$KEY" = "add-folder" ]; then
        add_folder "${@:2}"
        return 0
    elif [ "$KEY" = "rm" ]; then
        remove_note "${@:2}"
        return 0
    elif [ "$KEY" = "add" ]; then
        add_note "${@:2}"
        return 0
    elif [ "$KEY" = "exists" ]; then
        exists_note "${@:2}"
        return 0
    else
        echo "option ["$@"] doent not exists\n" 
        set_help
        return 1
    fi

}
main $@