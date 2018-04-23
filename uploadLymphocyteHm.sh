#!/bin/bash
# bash uploadLymphHm.sh <options>
# Authors: Alina Jasniewski, Joseph Balsamo

# Functions
# function: usage(brief)
function usage() {
    echo "Usage: $ ./uploadLymphHm.sh [options] -h <host> -f <filename>"
    if [ $1 == false ]
    then
      echo "  Options:"
      echo "    -f <filename>: filename of the data to be loaded (this parameter required)"
      echo "    -h <host>: ip or hostname of database (this parameter required)"
      echo "    -d <database name> (default: quip)"
      echo "    -p <database port> (default: 27017)"
      echo ""
      echo "    --help Display full help usage."
      echo "  Notes: requires mongoDB client tools installed on running server"
    fi
}
# end functions

# Set Default variables.
database="quip"
port="27017"
FILE=""
HOST=""
errcode=0
brief=true

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
    usage false
    exit 0
 
break ;;
 
*) usage true ;;
 
esac
 
shift
 
done

if [ -z "${HOST}" ] || [ -z "${FILE}" ]
then
  echo "Missing required parameters"
  usage true
  exit 1
fi

TYPE=${database}
HEATMAP="./${FILE}/heatmap_${FILE}.json"
META="./${FILE}/meta_${FILE}.json"


echo "mongoimport --port ${port} --host ${HOST} -d ${TYPE} -c objects ${HEATMAP}"
echo "mongoimport --port ${port} --host ${HOST} -d ${TYPE} -c metadata ${META}"

exit 0