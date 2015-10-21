# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
        # Shell is non-interactive.  Be done now!
        return
fi

# activate bash-completion: 
[ -f /etc/profile.d/bash-completion.sh ] && source /etc/profile.d/bash-completion.sh

alias makepasswd="/usr/bin/makepasswd --count=10 $@"
unset GREP_OPTIONS
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
