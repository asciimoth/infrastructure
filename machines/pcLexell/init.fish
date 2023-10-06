# Infrastructure config by ASCIIMoth
#
# To the extent possible under law, the person who associated CC0 with
# this work has waived all copyright and related or neighboring rights
# to it.
#
# You should have received a copy of the CC0 legalcode along with this
# work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

if not set -q LOGINER_USED
    if [ "$USER" != "root" ]
        set -gx LOGINER_USED TRUE
        loginer
    end
end

set GAPS " "
set DEFAULT_USER "moth"

set __BR_YELLOW (set_color bryellow)
set __BR_GREEN (set_color brgreen)
set __GREEN (set_color green)
set __BR_RED (set_color brred)

source /etc/theme.fish

function shgaps
  set -g GAPS $argv[1]
end

function cdd
	set tempfile (mktemp -t tmp.XXXXXX)
	command ranger --choosedir=$tempfile $argv
	set return_value $status

	if test -s $tempfile
		set ranger_pwd (cat $tempfile)
		if test -n $ranger_pwd -a -d $ranger_pwd
			builtin cd -- $ranger_pwd
		end
	end

	command rm -f -- $tempfile
	return $return_value
end

function dsu
  if count $argv > /dev/null
    if [ $history[$argv[1]] = "dsu" ]
      dsu (math $argv[1] + 1)
    else
      eval command sudo $history[$argv[1]]
    end
  else
    dsu 1
  end
end

function get_var_by_name
 set v (printf '$%s' $argv[1])
 eval echo $v
end

# Set var argv[1] to value argv[2] if argv[1] not exists
function set_if_not_exists
  # printf '"%s" "%s"' $argv[1] $argv[2]
  if not set -q $argv[1]
    set -gx $argv[1] $argv[2]
  end
end

# Set var argv[1] to value argv[2] if argv[1] not exists or if its value is ""
function set_if_not_exists_or_void
  if [ (get_var_by_name $argv[1]) = "" ]
    set -gx $argv[1] $argv[2]
  end
end

set_if_not_exists_or_void __LAST_STATUS_GENERATION "0"

function random64
 openssl rand -base64 33
end

function randomhex
 openssl rand -hex 20
end

# Run argv[1] with argv[2..] only once at session
# Saves already called commands in tmp file
function call_once
  set_if_not_exists_or_void ONCECALL (printf '/tmp/oncecall-%s' (randomhex))
  touch -a $ONCECALL
  chmod -f 777 $ONCECALL
  set command (string join -n " " $argv)
  set exist (echo (grep $command $ONCECALL))
  if [ (string length $exist) = "0" ]
    eval $command
    echo $command >> $ONCECALL
  end
end

function __print_greeting
  # TODO
  echo "Greeting"
end

function fish_greeting
  #echo $ONCECALL
  call_once __print_greeting
end

# If status is 0 return void string
# Otherwise retrun string with status code in brackets
function __get_status_view
  if [ $argv[1] != "0" ]
    set_color red
    printf "[%s]" $argv[1]
    set_color normal
  end
end

function __get_user_color
  if [ $USER = "root" ]
    set_color red
  else
    if test -d /home/$USER
      set_color green
    else
      set_color yellow
    end
  end  
end

function __get_prompt_arrow
  # TODO
  printf ">"
end

function __get_prompt_user_char
  if [ $USER = "root" ]
    printf "#"
  else
    if test -d /home/$USER
      printf "\$"
    else
      printf "\@"
    end
  end
end

function __render_block_host
  set DELIMITER "@"
  set USERNAME (printf '%s%s' (__get_user_color) $USER)
  if [ $USER = $DEFAULT_USER ]
    set DELIMITER ""
    set USERNAME ""
  end
  printf '%s[%s%s%s%s%s%s%s%s]' $__BR_YELLOW $GAPS $__BR_GREEN $hostname $__GREEN $DELIMITER $USERNAME $__BR_YELLOW $GAPS
end

function __render_block_path
  if [ (string split "$HOME" "$PWD" | wc -l) -eq 2 ]
    set PATHCOL $__BR_GREEN
  else
    set PATHCOL $__BR_RED
  end
  printf '%s[%s%s%s%s%s]' $__BR_YELLOW $GAPS $PATHCOL (prompt_pwd) $__BR_YELLOW $GAPS
end

function __render_block_shells
 if test $SHLVL -gt 1
  printf "%s(%sshlvl:%s%s%s)" $__BR_YELLOW $GAPS $SHLVL $GAPS $__BR_YELLOW 
 end
end

function add_gaps
  string join -n $GAPS $argv
end

function fish_prompt
  base16-load
  #history merge
  set -g STATUS $status
  if [ $__LAST_STATUS_GENERATION = $status_generation ]
    set -g STATUS "0"
  end
  set -g __LAST_STATUS_GENERATION $status_generation
  set USERCOL (__get_user_color)
  printf '%s\n' (add_gaps (__render_block_host) (__render_block_path) (__render_block_shells))
  printf '%s%s%s%s%s ' $USERCOL (__get_prompt_user_char) (__get_status_view $STATUS) $USERCOL (__get_prompt_arrow) 
  set_color normal
end

#function fish_right_prompt
#  printf '<'
#end

function fuck -d "Correct your previous console command"
  set -l fucked_up_command $history[1]
  env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
  if [ "$unfucked_command" != "" ]
    eval $unfucked_command
    builtin history delete --exact --case-sensitive -- $fucked_up_command
    builtin history merge
  end
end

if [ $USER = "root" ]
    printf "User root; do not load direnv"
else
    direnv hook fish | source
end


