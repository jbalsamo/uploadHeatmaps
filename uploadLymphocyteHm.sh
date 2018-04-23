#!/bin/bash
# bash uploadLymphHm.sh <options>
# Authors: Alina Jasniewski, Joseph Balsamo

# Set Default variables.
database="quip"
port="27017"
FILE=""
HOST=""


while [ -n "$1" ]
# while loop starts
do
case "$1" in
-h) HOST="$2"
    shift;;
-p) port="$2"
    shift ;;
 
-f) FILE=${2}
    shift;;

-d) database=${2}
    shift;;

--help)  
    echo "Usage: "
 
break ;;
 
*) echo "Option $1 not recognized";;
 
esac
 
shift
 
done

if [ -z "${HOST}"]
  exit 1;;
fi

TYPE=${database}
HEATMAP="./${FILE}/heatmap_${FILE}.json"
META="./${FILE}/meta_${FILE}.json"


echo "mongoimport --port ${port} --host ${HOST} -d ${TYPE} -c objects ${HEATMAP}"
echo "mongoimport --port ${port} --host ${HOST} -d ${TYPE} -c metadata ${META}"

exit 0