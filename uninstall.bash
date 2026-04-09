#!/bin/bash

if (( $# < 1 ))
then
	echo "Usage: $0 ~/skills/directory/to/install/to"
	exit 1
fi

TARGET_DIR="$1"


for x in ./*/SKILL.md
do
	full_path="$(realpath "${x%/SKILL.md}")"
	target_path="$TARGET_DIR/$(basename "$full_path")"
	echo "Removing symlink $target_path if it exists"
	rm "$target_path"
done
