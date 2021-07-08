set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat "${1}/env"`

# export: $pri_key, $user, $cnt, $hosts, $dirs
get_instance_info "${env}" 'true'

tag=`must_env_val "${env}" 'tidb.backup.tag'`

for (( i = 0; i < ${cnt}; ++i)) do
	host="${hosts[$i]}"
	dir="${dirs[$i]}"
	echo "[:-] '${host}:${dir}.${tag}' remove backup dir begin"
	ssh_exe "${host}" "rm -rf \"${dir}.${tag}\""
	echo "[:)] '${host}:${dir}.${tag}' remove backup dir done"
done
