set -uo pipefail

env=`cat "${1}/env"`

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/base.bash" "${env}" 'true'

tag=`env_val "${env}" 'tidb.backup.tag'`

for (( i = 0; i < ${cnt}; ++i)) do
	host="${hosts[$i]}"
	dir="${dirs[$i]}"
	ssh_exe "${host}" "rm -rf \"${dir}.${tag}\""
	echo "[:)] removed backup tag dir '${host}:${dir}.${tag}'"
done
