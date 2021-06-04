set -uo pipefail

env=`cat "${1}/env"`

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/base.bash" "${env}" 'false'

for (( i = 0; i < ${cnt}; ++i)) do
	host="${hosts[$i]}"
	dir="${dirs[$i]}"

	tags=`ssh_exe "${host}" 'for f in "'${dir}'".*; do echo "${f##*.}"; done'`
	if [ -z "${tags}" ] || [ "${tags}" == '*' ]; then
		echo "[:)] '${host}:${dir}' has not backup tags"
		continue
	fi

	echo "[:)] '${host}:${dir}' has backup tags:"
	echo "${tags}" | awk '{print "      "$0}'
done
