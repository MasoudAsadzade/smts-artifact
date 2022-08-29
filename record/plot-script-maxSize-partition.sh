#!/bin/bash

if [ $# -eq 0 ]; then 
	echo "Usage $0 <result-dir>"
	exit 1;
fi

resultdir=$1

name=$(basename resultdir)-$2


tmpdir=$resultdir/temp
if [ -d $tmpdir ]; then rm -rf $tmpdir; fi
mkdir -p $tmpdir

echo 'temp dir: ' $tmpdir


for file in lia_ms5_time lia_ms50_time lia_ms100_time lia_ms500_time lia_ms1000_time; do
  echo ${resultdir}/$file
	tail +1 ${resultdir}/$file \
		|awk '{print $2 "  " $0}' \
		|sort -k1 -n \
		|nl >$tmpdir/$file.list
done


(
	echo "set term pngcairo"
	echo "set output 'cactus-plot-"$name".png'"
#	echo "set logscale x"
#	echo "set logscale y"
	echo "set xlabel 'time'"
	echo "set ylabel 'number of instance'"
	echo -n "plot "

	for file in lia_ms5_time lia_ms50_time lia_ms100_time lia_ms500_time lia_ms1000_time; do
		echo -n "\"$tmpdir/$file.list\" using 2:1 title "\"$file-$2\"" with lines, "

	done
	echo
) | gnuplot
