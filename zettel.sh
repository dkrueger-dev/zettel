#!/bin/bash
#-------------------------------------------------------------------------------
# define required tools for the script
required=()

# check if required tools are installed
for tool in "${required[@]}"; do
    command -v $tool >/dev/null 2>&1 || { echo >&2 "Require \"$tool\" but it's not installed."; exit 1; }
done
#-------------------------------------------------------------------------------

# Creating a new note. Use current timestampt as prefix and markdown
# extension '.md' as extension. The note title will be inserted to the
# newly created file as markdown heading 1 '# Title'. File will be
# opened in your editor of choice, defined via $EDITOR environment
# variable.
create() {
  # Create new timestamp for note
  local timestamp=$(date +"%Y-%m-%d-%H%M")

  # Read note title from input
  read -p "Note title: " -r title

  # Create filename
  local filename="$timestamp $title.md" 

  # Create file and check if it is created
  local filepath="$home_dir/$filename" 
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

#-------------------------------------------------------------------------------

home_dir="${HOME}/Notizen"

# Check if home_dir exists
if [[ ! -d "$home_dir" ]]; then
  echo "Directory \"$home_dir\" does not exist."
  echo "Create it first."
  exit 1
fi

COMMAND=$1
if [[ -z ${COMMAND} ]]; then
  echo "No command specified."
  exit 1
fi

if [[ ${COMMAND} == "new" ]]; then
  create
  exit 0
fi

echo "Command \"${COMMAND}\" not found."
exit 1

#-------------------------------------------------------------------------------

# Creating a new note
create() {
  # Create new timestamp for note
  local timestamp=$(date +"%Y-%m-%d-%H%M")

  # Read note title from input
  read -p "Note title: " -r title

  # Create filename
  local filename="$timestamp $title.md" 

  # Create file and check if it is created
  local filepath="$home_dir/$filename" 
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
