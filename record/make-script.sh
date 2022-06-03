#!/bin/bash

if [ $# != 3 ]; then
    echo "Usage: $0 <provide benchs dir>"
    exit 1
fi
function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}
SCRIPT_ROOT=$(get_abs_path $(dirname $0))
#echo $SCRIPT_ROOT
total=0
bashstr=''


name=$(basename $1)
#echo $name

port=3000

gname=$name-$(date +'%F')
scriptdir=$SCRIPT_ROOT'/packed/'$name'/'
outd=$SCRIPT_ROOT'/result/'$name'/'
mkdir -p ${scriptdir}

n_benchmarks=$(find $1 -name '*.smt2' | wc -l)
echo "Benchmark set (total ${n_benchmarks}):"
#rm $outd$name-'remained'
((n_node=((n_benchmarks/($2*3)))))
echo "N Benchmark: ${n_benchmarks}"  "- N Node:  ${n_node}" - 'N bench per server:' $2 >> $outd$name-'remained'

echo "Number of Nodes (total ${n_node}):"
#n_remained=n_node-1
find $1 -name '*.smt2' |
while read -r file;
  do

    ((total=total+1))
#    if  [ ${total} -gt $((n_benchmarks-n_remained)) ]
#          then
#            echo $file >> $outd$name-'remained'
#    fi
    if  [ ${total} == $2 ]
        then
          filepaths+="'$file'"
       else
          filepaths+="'$file'",
     fi

    if  [ ${total} == $2 ]
      then

        if  [ ${port} == 3003 ]
          then
            port=3000

            echo $SCRIPT_ROOT'/packed/'$gname''-$n_node'.sh'
            n_node=$((n_node-1))
        fi

        command=$3'smts.py -o3 -p '$port' -fp '
        if  [ ${port} == 3002 ]
          then
            bashstr+="$command""$filepaths" ;
            bashstr+=" & wait"
#              echo $bashstr
            ex=$1;
            bname=`basename $ex`
            scrname=$SCRIPT_ROOT'/packed/'$name'/'$gname''-$n_node'.sh'
#            echo $scrname
            cat << _EOF_ > $scrname
#!/bin/bash
## Generated by $0
## From $ex
#SBATCH --time=00:35:00
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --mem=0
#SBATCH --partition=slim
#SBATCH --output=$outd/${gname}-$n_node.out
#SBATCH --error=$outd/${gname}-$n_node.err

output=$outd

_EOF_

#          i=$((i+1))
          cat << _EOF_ >> $scrname
 (
    chmod +x $scrname
    $bashstr
 ) > \$output/${gname}-$n_node.out & wait
_EOF_

        #    echo "wait" >> $packedscrd/$scrname
#            echo $packedscrd
#            echo $scrname

            bashstr=''
          else
            bashstr+="$command""$filepaths" ;
            bashstr+=" & "
        fi

        filepaths=''
        total=0
        ((port=port+1))
    fi

  done
echo "Construct and send the above jobs to batch queue?"
read -p "y/N? "

if [[ ${REPLY} != y ]]; then
    echo "Aborting."
    exit 1
fi

mkdir -p $outd
#${WORKSCRIPT} ${smtServer} ${scriptdir} ${resultdir} ${config} ${bmpath}/*.smt2.bz2
n_job=0
for script in ${scriptdir}/*.sh; do
    echo ${script};
    sh ${script};
    ((n_job=n_job+1))
    if  [ ${n_job} == 500 ]
          then
            sleep 1800
            n_job=0
    fi
#    sbatch ${script};
    sleep 1;
done


