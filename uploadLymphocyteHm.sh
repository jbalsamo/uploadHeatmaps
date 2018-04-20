#!/bin/bash
# bash uploadLymphHm.sh <options>
# Authors: Alina Jasniewski, Joseph Balsamo

# Set Default variables.
database="quip"
port="27017"


while [ -n "$1" ]
# while loop starts
do
case "$1" in
-h) host="$2"
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

TYPE="quip"
HEATMAP="./${FILE}/heatmap_${FILE}.json"
META="./${FILE}/meta_${FILE}.json"


mongoimport --port 27017 --host localhost -d ${TYPE} -c objects ${HEATMAP}
mongoimport --port 27017 --host localhost -d ${TYPE} -c metadata ${META}

exit 0