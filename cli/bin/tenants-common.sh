#!/bin/bash
#
# tenants-common.sh
#
# author: dooley@tacc.utexas.edu
#
# URL filter for tenants services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if (($development)); then
			if [[ -n "$AGAVE_DEV_TENANTS_API_BASEURL" ]]; then
				hosturl="$AGAVE_DEV_TENANTS_API_BASEURL/tenants"
			elif [[ -n "$devurl" ]]; then
				hosturl="${devurl}/tenants"
			else
				hosturl="https://agaveapi.co/tenants/"
			fi
		else
			if [[ -n "$AGAVE_TENANTS_API_BASEURL" ]]; then
				hosturl="$AGAVE_TENANTS_API_BASEURL"
			else
				hosturl="https://agaveapi.co/tenants/"
			fi
		fi
	fi

	#hosturl="${hosturl%&}"
}
