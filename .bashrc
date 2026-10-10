#
# ~/.bashrc
#

export PATH="~/bin:~/.cargo/bin:$PATH"
export TERMINAL=kitty
export EDITOR=vim

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

shopt -s checkwinsize

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

HISTSIZE=10000
HISTFILESIZE=10000

# Setup fzf
eval "$(fzf --bash)"

# Setup thefuck
# eval "$(thefuck --alias)"

# setup a timer to show how long the last command took
function timer_now {
	date +%s%N
}

function timer_start {
	timer_start=${timer_start:-$(timer_now)}
}

function timer_stop {
	local delta_us=$((($(timer_now) - $timer_start) / 1000))
	local us=$((delta_us % 1000))
	local ms=$((delta_us / 1000 % 1000))
	local s=$((delta_us / 1000000 % 60))
	local m=$((delta_us / 60000000 % 60))
	local h=$((delta_us / 3600000000))

	# show around 3 digits of accurcy
	if ((h > 0)); then timer_show=${h}h${m}m
	elif ((m > 0)); then timer_show=${m}m${s}s
	elif ((s >= 10)); then timer_show=${s}.$((ms / 100))s
	elif ((s > 0)); then timer_show=${s}.$(printf %03d $ms)s
	elif ((ms >= 100)); then timer_show=${ms}ms
	elif ((ms > 0)); then timer_show=${ms}.$((us / 100))ms
	else timer_show=${us}us
	fi

	unset timer_start
}

# setup custom prompt
set_prompt () {
	Last_Command=$?
	Blue='\[\e[01;34m\]'
	White='\[\e[01;37m\]'
	Red='\[\e[01;31m\]'
	Green='\[\e[01;32m\]'
	Yellow='\[\e[01;93m\]'
	Pink='\[\e[01;95m\]'
	Reset='\[\e[00m\]'
	FancyX='\342\234\227'
	Checkmark='\342\234\223'


	# Bright white exit status of last command 
	PS1="\n$White\$? "

	# If success, then green checkmark, else red X
	if [[ $Last_Command == 0 ]]; then
		PS1+="$Green$Checkmark"
	else
		PS1+="$Red$FancyX"
	fi
	

	# Add elapsed time and current date
	timer_stop
	PS1+="($timer_show) \t\n"
	
	# If in an environment, show
	virt_env=${VIRTUAL_ENV_PROMPT}
	PS1+="$Reset${virt_env:+($virt_env)\n}"

	unset virt_env

	# If root, print user in red, else green
	if [[ $EUID == 0 ]]; then
	        PS1+="$Red\\u$Green@\\h:"
	else
		PS1+="$Green\\u@\\h:"
	fi

	# Print the working directory, then reset the text color to default
	PS1+="$Blue\\w$Reset"

	# If git exists and we're in a git repo, add the current branch
	if git --version &> /dev/null && git log --oneline -n 1 &> /dev/null ; then
		local format
		if git symbolic-ref HEAD &> /dev/null ; then
			format=' at %C(bold brightyellow)%h%C(auto)%d'
		else
			format=' at %C(bold brightmagenta)%h%C(auto)%d %C(#FF8800)(detached)%C(reset)'
		fi

		PS1+="$(git log --color=always --pretty=format:"$format" -n 1)"
	fi

	# Print prompt marker
	PS1+="\n\n\$ "

}

trap 'timer_start' DEBUG
export PROMPT_COMMAND=(set_prompt)

# setup zoxide last
eval "$(zoxide init bash)"

# function to change current working directory with yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && { z && z -- "$cwd" || builtin cd -- "$cwd"; }
	rm -f -- "$tmp"
}

# if can, run fastfetch
which fastfetch &> /dev/null && fastfetch
