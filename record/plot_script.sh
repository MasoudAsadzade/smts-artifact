#!/bin/bash

if [ $# -eq 0 ]; then 
	echo "Usage $0 <result-file>"
	exit 1;
fi

result=$1
echo $3
echo $result
name=$(basename $result)-$2

tmpdir=$(mktemp -d)
echo $tmpdir
#trap "rm -rf $tmpdir" EXIT

for type in blind tterm bterm noteq eq tterm_neq portfolio; do
	tail +2 ${result} \
		|grep " $type " \
		|awk '{print $3 "  " $0}' \
		|sort -k1 -n \
		|nl >$tmpdir/$type.list
done

(
	echo "set term pngcairo"
	echo "set output 'cactus-plot-"$name".png'"
	echo "set logscale x"
	echo "set logscale y"
	echo "set xrange [100:1000]"
	echo "set yrange [700:1000]"
	echo "set xlabel 'time'"
	echo "set ylabel 'number of instances'"
	echo -n "plot "
	for type in blind tterm bterm noteq eq tterm_neq portfolio; do
		echo -n "\"$tmpdir/$type.list\" using 2:1 title "\"$type\"$3", "
	done
	echo
) |gnuplot
