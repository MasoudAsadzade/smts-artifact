#!/bin/bash


if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <reults-csv> <logic>"
    exit 1
fi

#RESULTS=~/Downloads/raw-results/raw-results-sq.csv
RESULTS=$1

logic=$2

echo Results from $RESULTS
echo Logic with $logic

while read -r solver; do
    solvers+=($solver);
done < <(
    csvgrep -c benchmark -m "/$logic/" $RESULTS \
    |csvcut -c 'solver id' \
    |tail +2 \
    |sort \
    |uniq
)

csvgrep -c benchmark -m "/$logic/" $RESULTS \
|csvcut -c benchmark \
|tail +2 \
|sort \
|uniq \
|while read -r instance; do
    ok=true
    for solver in "${solvers[@]}"; do
        nlines=$(\
	    csvgrep -c benchmark -m "${instance}" $RESULTS \
	    |csvgrep -c 'solver id' -m "$solver" \
	    |csvgrep -c 'result' -m 'starexec-unknown' \
	    |wc -l \
        )
	if [[ $nlines -eq 1 ]]; then
	    ok=false
	fi
    done
    if [[ $ok == "true" ]]; then
	echo $instance
    fi
done
