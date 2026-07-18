set_ps1() {
	# Color/style escape sequences
	bold() { echo '\[\e[1;'$1'm\]'; }
	local RESET='\[\e[0m\]'
	local CYAN=$(bold 36)
	local RED=$(bold 31)
	local WHITE=$(bold 37)
	local BLUE=$(bold 34)
	unset bold

	# Red username and `#` are reserved for root
	local USER PROMPT_CHAR
	if [ $UID = 0 ]; then
		USER_COLOR=$RED
		PROMPT_CHAR=\#
	else
		USER_COLOR=$WHITE
		PROMPT_CHAR=\$
	fi

	# Decide bracket color based on distro
	local BRACKET
	case $(grep '^ID=' /etc/os-release | cut -d'=' -f2) in
		nixos)   BRACKET=$CYAN ;; # Changed 'arch' to 'nixos'
		debian)  BRACKET=$RED ;;
		*)       BRACKET=$CYAN ;; # Fallback just in case
	esac

	# Colored prompt
	PS1="$BRACKET[ $USER_COLOR\u$RESET@\H $BLUE\W $BRACKET]$RESET$PROMPT_CHAR "
}

set_ps1
unset set_ps1
