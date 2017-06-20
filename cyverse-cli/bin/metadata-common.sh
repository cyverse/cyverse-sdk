#!/bin/bash
# 
# metadata-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for metadata services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/meta/"
		else
			hosturl="$baseurl/meta/$version/"
		fi
	fi
}

