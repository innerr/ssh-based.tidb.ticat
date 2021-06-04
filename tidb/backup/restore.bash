set -uo pipefail

env=`cat "${1}/env"`

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/base.bash" "${env}" 'true'

tag=`env_val "${env}" 'tidb.backup.tag'`

for (( i = 0; i < ${cnt}; ++i)) do
	host="${hosts[$i]}"
	dir="${dirs[$i]}"
	
	echo "[:-] prepare to restore '${host}:${dir}' form tag '${tag}'"
	cmd="rm -rf \"${dir}\" && rm -f \"${dir}.${tag}/data/space_placeholder_file\" && cp -rp \"${dir}.${tag}\" \"${dir}\""
	echo + ssh -i "${pri_key}" -o BatchMode=yes "${user}"@"${host}" ${cmd}
	ssh_exe "${host}" "${cmd}"
done
