#---------------------------------------------------
# File: Helper Function Library
#---------------------------------------------------

#---------------------------------------------------
# Function: chk_opt 
# Description: Takes an argument and determines if it 
#              is a flag instead of an parameter value.
# parameters: cl argument
# usage: opterr="$(chk_opt ${2})"
#---------------------------------------------------
function chk_opt() {
  # Check the first char of the option passed 
  checkc="$(echo $1 | head -c 1)"

  if [ $checkc == "-" ]
  then
    echo 'true'
  else
    echo 'false'
  fi
}
#-----------------------------------------------------------------------
# End chk_opt
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# end functions
#-----------------------------------------------------------------------
