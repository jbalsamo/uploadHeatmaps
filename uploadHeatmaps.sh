#!/bin/bash
#---------------------------------------------------
# bash uploadHeatmaps.sh <options>
# Description: This script manages the conversion and
#              upload of heatmaps to a containerized
#              pathdb instance of quip.
# Author(s): Joseph Balsamo
#---------------------------------------------------

#---------------------------------------------------
# Source Function Libraries
#---------------------------------------------------
source helpers.sh
source readpass.sh

#---------------------------------------------------
# Function Definitions
#---------------------------------------------------

#---------------------------------------------------
# Function: usage(brief)
# Description: Display help message.  When true is passed 
#              it will show a brief version showing the 
#              bare minimum flags needed.
# parameters: brief
# usage: usage [true | false]
#---------------------------------------------------
function usage() {
    echo "Usage: $ uploadHeatmaps.sh [options] -c <pathDB_collection>"
    if [ $1 == false ]
    then
      echo "  Options:"
      echo "    -c, --collection <pathDB_collection>: PathDB Collection for heatmaps (*this parameter required)"
      echo "    -i, --input <input_folder>: Folder where heatmaps are loaded from (default: /mnt/data/xfer/input)"
      echo "    -o, --output <output_folder>: Folder where converted heatmaps are imported from (default: /mnt/data/xfer/output)"
      echo "    -q, --quip-host <host>: ip or hostname of PathDB Server (default: quip-pathdb)"
      echo "    -h, --data-host <host>: ip or hostname of database (default: ca-mongo)"
      echo "    -d, --database <database name> (default: camic)"
      echo "    -p, --port <database port> (default: 27017)"
      echo ""
      echo "    --help Display full help usage."
      echo "  Notes: requires mongoDB client tools installed on running server"
    fi
}
#-----------------------------------------------------------------------
# End usage
#-----------------------------------------------------------------------

#---------------------------------------------------
# End Function Definitions
#---------------------------------------------------

#-----------------------------------------------------------------------
# Main Script
#-----------------------------------------------------------------------

# Set Default variables.
database="camic"
port="27017"
HOST="ca-mongo"
errcode=0
brief=true

# Loop through all command-line arguments.
while [ -n "$1" ]
# while loop starts
do
  # Process command-line flags
  # Start Case
  case "$1" in
    -q | --quip-host) 
        opterr="$(chk_opt ${2})"
        if [ $opterr ==  'true' ]
        then
          echo "Error: Missing parameter."
          exit 5
        else
          qhost="$2"
          shift
        fi;;
    -h | --data-host) 
        opterr="$(chk_opt ${2})"
        if [ $opterr ==  'true' ]
        then
          echo "Error: Missing parameter."
          exit 5
        else
          host="$2"
          shift
        fi;;
    -p | --port) 
        opterr="$(chk_opt ${2})"
        if [ $opterr ==  'true' ]
        then
          echo "Error: Missing parameter."
          exit 5
        else
          port="$2"
          shift
        fi;;
    -c | --collection) 
        opterr="$(chk_opt ${2})"
        if [ $opterr ==  'true' ]
        then
          echo "Error: Missing parameter."
          exit 5
        else
          collection="$2"
          shift
        fi;;
    -m | --manifest) 
        opterr="$(chk_opt ${2})"
        if [ $opterr ==  'true' ]
        then
          echo "Error: Missing parameter."
          exit 5
        else
          manifest="$2"
          shift
        fi;;
    -i | --input) 
        opterr="$(chk_opt ${2})"
        if [ $opterr ==  'true' ]
        then
          echo "Error: Missing parameter."
          exit 5
        else
          in="$2"
          shift
        fi;;
    -o | --output) 
        opterr="$(chk_opt ${2})"
        if [ $opterr ==  'true' ]
        then
          echo "Error: Missing parameter."
          exit 5
        else
          out=${2}
          shift
        fi;;
    -d | --database) 
        opterr="$(chk_opt ${2})"
        if [ $opterr ==  'true' ]
        then
          echo "Error: Missing parameter."
          exit 5
        else
          database=${2}
          shift
        fi;;
    --help)  
        usage false
        exit 0;;
    *) usage true;; 
  esac
  # End of Case
  shift
done
# End of While

# Request username and password for upload.
uname="$(getPrompt 'Username:')"
passw="$(getPass 'Password:')"

if [ -z "${collection}" ]  
then
  echo "Missing required parameter"
  usage true
  exit 1
fi

# Set default values for unprovided options.
if [ -z "${host}" ]
then
  host="ca-mongo"
fi
if [ -z "${qhost}" ]
then
  qhost="quip-pathdb"
fi
if [ -z "${manifest}" ]
then
  manifest="manifest.csv"
fi
if [ -z "${in}" ]
then
  in="/mnt/data/xfer/input"
fi
if [ -z "${out}" ]
then
  out="/mnt/data/xfer/output"
fi
if [ -z "${port}" ]
then
  port="27017"
fi
if [ -z "${database}" ]
then
  database="camic"
fi

# Check that input and output folders exist.  
if [ ! -f $in ]
then
  echo "Error: Input folder does not exist."
  exit 2
fi
if [ ! -f $out ]
then
  echo "Error: Output folder does not exist."
  exit 3
fi

# Verify that PathDB Server is reachable using current username/password combo
ret_code="$(curl -Is -u ${uname}:${passw} http://${qhost}/ | head -1  | awk '{ print $2 }')"
if [ ! $ret_code -lt 400 ]
then
  echo "Error: PathDB Server is unreachable."
  exit 100
fi

# Convert heatmap data in the 'in' folder into uploadable json in the 'out' folder.
node --max_old_space_size=16384 /usr/local/bin/convert_heatmaps.js -h ${qhost} -c ${collection} -m ${manifest} -i ${in} -o ${out} -u ${uname} -p ${passw}
exitStatus=$?
# Check to see conversion process succeded.
if [[ $exitStatus == 0 ]]
then
  # Import into the quip database
  for filename in ${out}/*.json ; do
    mongoimport --port ${port} --host ${host} -d ${database} -c heatmap ${filename}
  done
else
  rm -f ${out}/*
  exit $exitStatus
fi

# exit normally
exit 0