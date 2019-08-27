#---------------------------------------------------
# File: ReadPass Function Library
#---------------------------------------------------

#---------------------------------------------------
# Function: getPrompt
# Description: Read a line of input hile echoing on
#              the screen. 
# parameters: prompt
# usage: myvar="$(getPrompt 'prompt')"
#---------------------------------------------------
function getPrompt() {
    prompt="$1 "
    read -p "$prompt" input
    echo "$input"
}
#---------------------------------------------------
# End getPrompt
#---------------------------------------------------

#---------------------------------------------------
# Function: getPass
# Description: Read a line of input while showing '*'
#              on the screen. 
# parameters: prompt
# usage: myPW="$(getPass 'prompt')"
#---------------------------------------------------
function getPass() {
    prompt="$1 "
    # Loop to get all characters of the password
    while IFS= read -p "$prompt" -r -s -n 1 char 
    do
        # Check if the return key was pressed
        if [[ $char == $'\0' ]];     then
            break
        fi
        # Check to see if backspace was pressed
        if [[ $char == $'\177' ]];  then
            l=${#password} # length of password
            # if l is > 0 then delete last char
            # else do not remove any character
            if [[ l -gt 0 ]]
            then
                prompt=$'\b \b'
                password="${password%?}"
            else
                prompt=$''
            fi
        else
            # Add new char to password
            prompt='*'
            password+="$char"
        fi
    done
    # Echo out password to be able to capture
    echo "$password"
}
#---------------------------------------------------
# End getPass
#---------------------------------------------------

#---------------------------------------------------
# End Function Library
#---------------------------------------------------
