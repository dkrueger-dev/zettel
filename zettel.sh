#!/bin/bash
#-------------------------------------------------------------------------------
# define required tools for the script
required=(fzf)

# check if required tools are installed
for tool in "${required[@]}"; do
    command -v $tool >/dev/null 2>&1 || { echo >&2 "Require \"$tool\" but it's not installed."; exit 1; }
done
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
fi
