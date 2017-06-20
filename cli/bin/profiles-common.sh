#!/bin/bash
# 
# profiles-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for profiles services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/profiles/"
		else
			hosturl="$baseurl/profiles/$version/"
		fi
	fi
}

