#!/bin/bash

LEADERBOARD=$HOME/leaderboard
DATAROOT=$HOME/leaderboard/data
ASSIGNMENTS="$LEADERBOARD"
USERFILE="$LEADERBOARD"/users.txt

CURR_ASSIGNMENT="${1:-0}"

[[ -d "$DATAROOT" ]] || mkdir -p "$DATAROOT"
if [[ ! -d "$DATAROOT" ]]; then
	echo "Could not create data directory $DATAROOT." >&2
	exit 1
fi

"$LEADERBOARD"/scripts/download-all.pl \
	--users "$USERFILE" \
	--root "$ASSIGNMENTS" \
	--file "assignment${CURR_ASSIGNMENT}.txt"
"$LEADERBOARD"/scripts/build-table.pl \
	--users "$USERFILE" \
	--root "$ASSIGNMENTS" \
	--assignment "$CURR_ASSIGNMENT" \
	> "$LEADERBOARD"/leaderboard.js

if [[ ! -e "$DATAROOT"/leaderboard.js ]]; then
	mv "$LEADERBOARD"/leaderboard.js "$DATAROOT"/leaderboard.js
	exit 0
elif diff "$LEADERBOARD"/leaderboard.js "$DATAROOT"/leaderboard.js > /dev/null
then
	# leaderboard.js hasn't changed.
	exit 0
fi

stamp=$(date +"%F-%H-%M")
sed 's/var data/var olddata/' <"$DATAROOT"/leaderboard.js \
	>"$DATAROOT"/leaderboard.js.$stamp
ln -sf "$DATAROOT"/leaderboard.js.$stamp "$DATAROOT"/leaderboard-old.js
mv "$LEADERBOARD"/leaderboard.js "$DATAROOT"/leaderboard.js
