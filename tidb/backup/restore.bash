set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat "${1}/env"`

# export: $pri_key, $user, $cnt, $hosts, $dirs
get_instance_info "${env}" 'true'

tag=`must_env_val "${env}" 'tidb.backup.tag'`

for (( i = 0; i < ${cnt}; ++i)) do
	host="${hosts[$i]}"
	dir="${dirs[$i]}"
	echo "[:-] restore '${host}:${dir}' from tag '${tag}' begin"
	cmd="rm -rf \"${dir}\" && rm -f \"${dir}.${tag}/data/space_placeholder_file\" && cp -rp \"${dir}.${tag}\" \"${dir}\""
	ssh_exe "${host}" "${cmd}"
	echo "[:)] restore '${host}:${dir}' from tag '${tag}' finish"
done
