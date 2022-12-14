#!/bin/bash
#-------------------------------------------------------------------------------
# define required tools for the script
required=(fzf rg)

# check if required tools are installed
for tool in "${required[@]}"; do
    command -v $tool >/dev/null 2>&1 || { echo >&2 "Require \"$tool\" but it's not installed."; exit 1; }
done
#-------------------------------------------------------------------------------

# Function for asking user a yes-or-no question.
# Usage: ask_user $message
ask_user() {
    # read user input
    read -p "$1 [yes/no]: " answer

    # disable case matching
    shopt -s nocasematch
    while [[ ! $answer =~ (y|yes) ]] && [[ ! $answer =~ (n|no) ]]; do
        echo "Please answer with 'yes' or 'no'..."

        # read user input
        read -p "$1 [yes/no]: " answer
    done

    if [[ $answer =~ (y|yes) ]]; then
        return 0 # return true
    else
        return 1 # return false
    fi
}

# Creating a new note. Use current timestamp as prefix and markdown
# extension '.md' as extension. The note title will be inserted to the
# newly created file as markdown heading 1 '# Title'. File will be
# opened in your editor of choice, defined via $EDITOR environment
# variable.
create_cmd() {
    # Create new timestamp for note
    local timestamp=$(date +"%Y-%m-%d-%H%M")

    # Read note title from input
    read -p "Note title: " -r title

    # Create filename
    local filename="$timestamp $title.md" 

    # Create file and check if it is created
    local filepath="$zettel_dir/$filename" 
    touch "$filepath"
    if [[ -f "$filepath" ]]; then
        echo "File \"$filepath\" created."
    else
        echo "Failed creating file."
        exit 1
    fi
  
    # Write title to document
    echo "# $title" > "$filepath" 
  
    # Open file in editor
    ${EDITOR} "$filepath" 
}

# Edit an existing note. For finding the note to edit, the function will
# change into home directory and call fzf. The note will be opened in
# editor of choice, defined via $EDITOR environment variable.
edit_cmd() { 
    # Change into home directory
    cd "$zettel_dir"

    # Run fzf to get filename
    file="$(fzf)" 
    
    # Call editor with file selected via fzf
    if [[ ! -z "$file" ]]; then
        ${EDITOR} "$file" 
    fi 
}

# The find function searches within file contents and file names. The
# search powered by ripgrep piped to fzf. The corresponding file will be
# opened in editor.
find_cmd() { 
    # Change into home directory
    cd "$zettel_dir"

    # Run rg and fzf to get filename
    file="$(rg --line-number --column . | fzf)" 
    
    # Call editor with file selected
    if [[ ! -z "$file" ]]; then
        ${EDITOR} "$file" 
    fi 
}

# Via search function a file content search via ripgrep is done on all
# notes in specified note home directory.
# Usage: search_cmd $pattern
search_cmd() {
    local pattern=$1

    # Check for pattern parameter
    if [[ -z $pattern ]]; then
        echo "No pattern specified."
        exit 1
    fi

    rg --heading --line-number --column "$pattern" "$zettel_dir" 
}

# The link command will create an markdown link from the selected file.
# The first line of the file must contain the title.
link_cmd() {
    # Change into home directory
    cd "$zettel_dir"

    # Run fzf to get filename
    file="$(fzf)"
    
    # Call editor with file selected via fzf
    if [[ ! -z "$file" ]]; then
        # Get the title from first line of file
        local title=$(head -n 1 "$file" | sed 's/# //g')
        echo "[$title]($file)"
    fi
}

# Tags function lists all used tags. The function can be used for
# filtering notes by tag or for tags management.
tags_cmd() {
    # rg does content search with regex for tags and group by file
    # sed remove all empty lines
    # sort sorts all tags aplhabetically
    # uniq remove doubled entries
    rg --only-matching --no-filename --no-line-number -e "#[A-Za-z-]+" \
        "$zettel_dir" \
        | sed '/\n/d' \
        | sort -n \
        | uniq
}

#-------------------------------------------------------------------------------

zettel_dir="${ZETTEL_DIR}"

# Check if zettel_dir exists
if [[ ! -d "$zettel_dir" ]]; then
    echo "Directory \"$zettel_dir\" does not exist."
    echo "Create it first."
    exit 1
fi

COMMAND=$1
if [[ -z ${COMMAND} ]]; then
    echo "No command specified."
    exit 1
fi

if [[ ${COMMAND} == "create" ]]; then
    # Call create function
    create_cmd
    exit 0
elif [[ ${COMMAND} == "edit" ]]; then
    # Call edit function
    edit_cmd
    exit 0
elif [[ ${COMMAND} == "find" ]]; then
    # Call find function
    find_cmd
    exit 0
elif [[ ${COMMAND} == "search" ]]; then
    # Call search function with search pattern as argument
    search_cmd "$2"
    exit 0
elif [[ ${COMMAND} == "link" ]]; then
    # Call link function
    link_cmd
    exit 0
elif [[ ${COMMAND} == "tags" ]]; then
    # Call tags function
    tags_cmd
    exit 0
fi

echo "Command \"${COMMAND}\" not found."
exit 1

