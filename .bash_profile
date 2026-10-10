#
# ~/.bash_profile
#

# If can, start uwsm
if uwsm check may-start; then
	exec uwsm start default
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
