MY_USERNAME=$(whoami)
###-------------------------- CUSTOM COMMANDS --------------------------###
export PS1='\[\e[38;5;16;48;5;226m\] \u @\h \[\e[38;5;16;48;5;87m\]\w\[\e[0m\] \n\[\e[1;38;5;87m\][$(date "+%d-%m-%Y %H:%M:%S")] \\$ \[\e[0m\]'
#export PS1='\[\e[38;5;16;48;5;226m\] \u @\h \[\e[38;5;16;48;5;87m\]\w\[\e[0m\] \n\[\e[1;38;5;87m\][\T] \\$ \[\e[0m\]'
#export PS1='\[\e[1;38;5;46m\]\u\[\e[0m\]@\[\e[1;38;5;75m\]\h \[\e[38;5;214m\]\w\[\e[0m\]\n\[\e[1;38;5;201m\]➤ \[\e[0m\]'
#export PS1='\[\e[1;38;5;199m\]╭─\[\e[38;5;39m\]\u@\h \[\e[38;5;226m\]\w\[\e[0m\]\n\[\e[1;38;5;199m\]╰─\$ \[\e[0m\]'
#export PS1='\[\e[1;38;5;39m\]╭─[\u@\h] \[\e[38;5;226m\]\w\n\[\e[1;38;5;39m\]╰─$ \[\e[0m\]'

HISTTIMEFORMAT="%d-%m-%Y %H:%M:%S "

[ -r ~/.dir_colors ] && eval "$(dircolors ~/.dir_colors)"
bind -f /home/.inputrc

###-------------------------- Alias Section --------------------------###
alias v="vim"					  	
alias gv="gvim" 					
alias csvfile="libreoffice --calc"
alias rl="realpath"				
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias zgrep="zgrep --color=auto"
alias ls="ls --color=auto"
alias ll="ls -l"	  				
alias lt="ls -lrt"					
alias la="ls -lart"
alias lR="ls -R"
alias l="lt"
alias c="clear"
alias d="display"
alias b="block"
alias a="source ~jm075679/.bashrc"
alias reload="source ~jm075679/.bashrc"
alias vibash="vim ~/.bashrc"
alias pdfopen="xdg-open"
alias cdp="cd -"
alias 1="cd .."
alias 2="cd ../../"
alias 3="cd ../../.."
alias 4="cd ../../../.."
alias 5="cd ../../../../.."
alias 6="cd ../../../../../.."
alias 7="cd ../../../../../../.."
alias 8="cd ../../../../../../../.."
alias 9="cd ../../../../../../../../.."

bakdef() {
	mv "$1/$MY_BLOCK.def.gz" "$1/$MY_BLOCK.def.bak.gz"
}
bakv() {
	mv "$1/$MY_BLOCK.v.gz" "$1/$MY_BLOCK.v.bak.gz"
}
bakall() {
	bakdef $1
	bakv $1
}
ldir() {
	l -d $1*
}
tcl_agg_vic_noise_nets() {
	if [ -t 0 ] && [ $# -eq 0 ]; then
		echo "Usage: tcl_agg_vic_noise_nets <file.txt|file.gz>" >&2
		return 1
	fi
	# Detect file type or read from stdin
	if [ $# -eq 0 ]; then
		INPUT_CMD="cat"  # From stdin
	elif file "$1" | grep -q 'gzip compressed'; then
		INPUT_CMD="zcat \"$1\""
	else
		INPUT_CMD="cat \"$1\""
	fi
	eval "$INPUT_CMD" | awk '
	/\([^)]*\)/ && !/pin/ {
		gsub("[()]", "", $2);
		print $2
	}
	/Aggressors:/, /Propagated:/ {
		print ", " $1
	}' |
	egrep -v "Aggressors:|Propagated:" |
	awk '
	/^[^,]/ {
		if (v != "") print "set net(" v ") [list" a "]"
		v = $1
		a = ""
	}
	/^,/ {
		gsub(/^, */, "", $0)
		a = a " " $1
	}
	END {
		if (v != "") print "set net(" v ") [list" a "]"
	}'
}
eco_pt2invs() {
	if [ ! -t 0 ]; then
		# Input is from a pipeline
		INPUT_CMD="cat"
		OUTPUT_CMD="cat"  # print to stdout
	elif [ $# -eq 0 ]; then
		echo "Usage: eco_pt2invs <file.tcl>  OR  use with a pipe" >&2
		return 1
	else
		INPUT_FILE="$1"
		OUTPUT_FILE="${INPUT_FILE%.*}.enc.tcl"
		INPUT_CMD="cat \"$INPUT_FILE\""
		OUTPUT_CMD="tee \"$OUTPUT_FILE\""
	fi
	eval "$INPUT_CMD" | grep -v "current_instance" | \
	sed -E 's/\[get_pins |\[get_cells |\]//g' | \
	awk '
	/insert_buffer/ {
		print "ecoAddRepeater -term " $2 " -cell " $3 " -newNetname " $5 " -name " $7
	}
	/size_cell/ {
		print "ecoChangeCell -inst " $2 " -cell " $3
	}
	/remove_buffer/ {
		print "ecoDeleteRepeater -inst " $2
	}' | eval "$OUTPUT_CMD"
}
eco_pt2dmsa() {
	if [ ! -t 0 ]; then
		# Input is from a pipeline
		INPUT_CMD="cat"
		OUTPUT_CMD="cat"
	elif [ $# -eq 0 ]; then
		echo "Usage: eco_pt2dmsa <file.tcl>  OR  use with a pipe" >&2
		return 1
	else
		INPUT_FILE="$1"
		OUTPUT_FILE="${INPUT_FILE%.*}.dmsa.tcl"
		INPUT_CMD="cat \"$INPUT_FILE\""
		OUTPUT_CMD="tee \"$OUTPUT_FILE\""
	fi
	eval "$INPUT_CMD" | \
	sed -E 's/\[get_pins |\[get_cells |\]//g' | \
	eval "$OUTPUT_CMD"
}
get_skew_latency() {
	if [ $# -eq 0 ] ; then
		input="/dev/stdin"
		cat_cmd="cat"
	else
		input="$1"
		if [[ "$input" == *.gz ]]; then
			cat_cmd="zcat"
		else
			cat_cmd="cat"
		fi
	fi
	$cat_cmd "$input" | awk '/Skew Group Summary:/,/* - indicates that target was not met/ {print}' | grep -i "SkewGrp" | sed 's/  \{2,\}/|/g' | awk -F'|' 'BEGIN{print "Timing Corner|Skew Group|ID Target|Min ID|Max ID|Avg ID|Std.Dev. ID|Skew Target Type|Skew Target|Skew|Skew window occupancy"}/^delayCorner_/ {print;corner=$1} /^\|/{print corner$0}' | awk -F'|' '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11}'
}
alias g="gstat"
alias bpri="bswitch priority"
alias bxla="bswitch xlarge"
alias bmed="bswitch medium"
alias bj="bjobs"
alias bs="bswitch"
alias bk="bkill"
alias bq="bqueues"
alias bl="blimits -u $MY_USERNAME"
alias bqa="bqueues xlarge priority large medium small short mp"
alias sz='du -sh --apparent-size'
alias sizecd='du -sch --apparent-size ./*'

get_pins() {
	local pattern="$1"
	local file="$2"
	awk -v pattern="$pattern" '
	BEGIN {output = "set pins {"; first = 1}
	$0 ~ pattern {flag = 1; next} 
	flag && $1 == "-" { if (first) {output = output $2; first = 0} else {output = output " " $2}}
	flag && (!NF || $1 != "-") {flag = 0; print output "}"; exit}
	END { if (flag) {print output "}"}}' "$file"
}
getillegalpins() {
	local file=$1
	get_pins "Illegally Assigned Pins:" "$file"
}
getinternalpins() {
	local file=$1
	get_pins "Internal Pins:" "$file"
}
getunplacepins() {
	local file=$1
	get_pins "Unplaced Pins:" "$file"
}
getdrcs() {
	local file="$1"
	awk '/^RULECHECK/{gsub(/\.{2,}/,"",$2);print $2" = "$7}' "$file"
}

alias sed_replace_pipe='sed "s/|/ /g"'
alias sed_digit_star='sed "s/\[\([0-9]\)\+\]/[*]/g"'
alias getclkperiod="awk '/create_clock/ {print \$3,\$5,\$7,\$8,\$9,\$10}'"

alias getsetup='grep -A4 "Setup mode" | grep -v "\-\-\-\-\-\-\-\-\-\-" | sed_replace_pipe | awk '\''{$1=$2=$3=""; print}'\'' | awk '\''BEGIN{line=""} NR==1 {print}  NR!=1 {for (i = 1; i <= NF; i++) col[i] = col[i] $i ","; } END { for (i = 1; i <= length(col); i++) printf "%s", col[i]; print ""}'\'''
alias gethold='grep -A4 "Hold mode" | grep -v "\-\-\-\-\-\-\-\-\-\-" | sed_replace_pipe | awk '\''{$1=$2=$3=""; print}'\'' | awk '\''BEGIN{line=""} NR==1 {print}  NR!=1 {for (i = 1; i <= NF; i++) col[i] = col[i] $i ","; } END { for (i = 1; i <= length(col); i++) printf "%s", col[i]; print ""}'\'''
alias getlogsetup='grep -A4 "Setup mode"'
alias zgetlogsetup='zgrep -A4 "Setup mode"'
alias getloghold='grep -A4 "Hold mode"'
alias zgetloghold='zgrep -A4 "Hold mode"'
alias getavomaxcap="awk 'BEGIN{f=0;p=0} /max_capacitance/{f=1} f && /Pin/{p=1} f && p {print} f&&p&&NF==0{f=0;p=0}' | awk '/VIOLATED/'"
alias getavomaxtran="awk 'BEGIN{f=0;p=0} /max_transition/{f=1} f && /Pin/{p=1} f && p {print} f&&p&&NF==0{f=0;p=0}' | awk '/VIOLATED/'"
getavomaxcapfile() {
	awk 'BEGIN{f=0;p=0}
		 /max_capacitance/{f=1}
		 f && /Pin/{p=1}
		 f && p {print}
		 f && p && NF==0{f=p=0}' "$@" |
	awk '/VIOLATED/' |
	awk '{print "set max_cap_pins("NR") [list "$1,$5"]"}'
}
getavomaxtranfile() {
	awk 'BEGIN{f=0;p=0}
		 /max_transition/{f=1}
		 f && /Pin/{p=1}
		 f && p {print}
		 f && p && NF==0{f=p=0}' "$@" |
	awk '/VIOLATED/' |
	awk '{print "set max_tran_pins("NR") [list "$1,$5"]"}'
}
get_invs_BES() {
	if [ -t 0 ]; then  # input is from terminal, so expecting a file
		local file="$1"
		if [[ -z "$file" ]]; then
			echo "Usage: get_invs_BES <file.tarpt or .tarpt.gz>"
			return 1
		elif [[ "$file" == *.gz ]]; then
			zcat "$file"
		else
			cat "$file"
		fi
	else
		cat  # read from pipeline
	fi | awk '
		/Beginpoint:/ { print ", " $2 }
		/Endpoint:/   { print $2 }
		/Slack Time/  {
			for (i=1; i<=NF; i++) {
				if ($i == "Time") {
					print "? " $(i+1)
					break
				}
			}
		}' | sed ':a;N;$!ba;s/\n, / /g' \
		   | sed ':a;N;$!ba;s/\n? / /g' \
		   | awk '{print $2, $1, $NF}'
}
#>>> Proceed with caution, Optimized for speed and coolness <<<\033[0m"
#echo "    /\$\$\$\$\$                     /\$\$                  /\$\$                           /\$\$                          ";
#echo "   |__  \$\$                    | \$/                 | \$\$                          | \$\$                          ";
#echo "      | \$\$  /\$\$\$\$\$\$  /\$\$   /\$\$|_//\$\$\$\$\$\$\$          | \$\$\$\$\$\$\$   /\$\$\$\$\$\$   /\$\$\$\$\$\$\$| \$\$\$\$\$\$\$   /\$\$\$\$\$\$   /\$\$\$\$\$\$\$";
#echo "      | \$\$ |____  \$\$| \$\$  | \$\$  /\$\$_____/          | \$\$__  \$\$ |____  \$\$ /\$\$_____/| \$\$__  \$\$ /\$\$__  \$\$ /\$\$_____/";
#echo " /\$\$  | \$\$  /\$\$\$\$\$\$\$| \$\$  | \$\$ |  \$\$\$\$\$\$           | \$\$  \\ \$\$  /\$\$\$\$\$\$\$|  \$\$\$\$\$\$ | \$\$  \\ \$\$| \$\$  \\__/| \$\$      ";
#echo "| \$\$  | \$\$ /\$\$__  \$\$| \$\$  | \$\$  \\____  \$\$          | \$\$  | \$\$ /\$\$__  \$\$ \\____  \$\$| \$\$  | \$\$| \$\$      | \$\$      ";
#echo "|  \$\$\$\$\$\$/|  \$\$\$\$\$\$\$|  \$\$\$\$\$\$\$  /\$\$\$\$\$\$\$/       /\$\$| \$\$\$\$\$\$\$/|  \$\$\$\$\$\$\$ /\$\$\$\$\$\$\$/| \$\$  | \$\$| \$\$      |  \$\$\$\$\$\$\$";
#echo " \\______/  \\_______/ \\____  \$\$ |_______/       |__/|_______/  \\_______/|_______/ |__/  |__/|__/       \\_______/";
#echo "                     /\$\$  | \$\$                                                                                 ";
#echo "                    |  \$\$\$\$\$\$/                                                                                 ";
#echo "                     \\______/                                                                                  ";
echo "   __     ______     __  __     ______        ______     ______     ______     __  __     ______     ______    ";
echo "  /\\ \\   /\\  __ \\   /\\ \\_\\ \\   /\\  ___\\      /\\  == \\   /\\  __ \\   /\\  ___\\   /\\ \\_\\ \\   /\\  == \\   /\\  ___\\   ";
echo " _\\_\\ \\  \\ \\  __ \\  \\ \\____ \\  \\ \\___  \\     \\ \\  __<   \\ \\  __ \\  \\ \\___  \\  \\ \\  __ \\  \\ \\  __<   \\ \\ \\____  ";
echo "/\\_____\\  \\ \\_\\ \\_\\  \\/\\_____\\  \\/\\_____\\     \\ \\_____\\  \\ \\_\\ \\_\\  \\/\\_____\\  \\ \\_\\ \\_\\  \\ \\_\\ \\_\\  \\ \\_____\\ ";
echo "\\/_____/   \\/_/\\/_/   \\/_____/   \\/_____/      \\/_____/   \\/_/\\/_/   \\/_____/   \\/_/\\/_/   \\/_/ /_/   \\/_____/ ";
echo "                                                                                                               ";
