

_terrain() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "apps hierarchies jobs" -- $cur) )
    
    elif [ $COMP_CWORD -eq 2 ]; then
        case "$prev" in
	    app|apps)		   COMPREPLY=( $(compgen -W "description list search" -- $cur) ) ;;
	    hierarchy|hierarchies) COMPREPLY=( $(compgen -W "list" -- $cur) ) ;;
	    job|jobs)		   COMPREPLY=( $(compgen -W "submit template" -- $cur) ) ;;
	    *)			   COMPREPLY=( $(compgen -f $cur)) ;;
	esac

    elif [ $COMP_CWORD -gt 2 ]; then
	case "$prev" in
	    -f|--description_file)	COMPREPLY=( $(compgen -f $cur)) ;;
	    *)				;;
	esac
    fi
}

#complete -F _terrain terrain-apps-description.py terrain-apps-list-by-hierarchy.py terrain-apps-search.py terrain-hierarchies-list.py terrain-jobs-submit.py terrain-jobs-template.py
complete -F _terrain terrain
