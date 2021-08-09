set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat "${1}/env"`

# export: $pri_key, $user, $cnt, $hosts, $dirs
get_instance_info "${env}" 'false'

for (( i = 0; i < ${cnt}; ++i)) do
	host="${hosts[$i]}"
	dir="${dirs[$i]}"

	tags=`ssh_exe "${host}" 'for f in "'${dir}'".*; do echo "${f##*.}"; done' true`
	if [ -z "${tags}" ] || [ "${tags}" == '*' ]; then
		echo "[:)] '${host}:${dir}' has not backup tags"
		continue
	fi

	echo "[:)] '${host}:${dir}' has backup tags:"
	echo "${tags}" | awk '{print "      "$0}'
done
