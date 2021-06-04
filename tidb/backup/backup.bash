set -uo pipefail

env=`cat "${1}/env"`

here=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
. "${here}/base.bash" "${env}" 'true'

tag=`env_val "${env}" 'tidb.backup.tag'`

for (( i = 0; i < ${cnt}; ++i)) do
	host="${hosts[$i]}"
	dir="${dirs[$i]}"
	
	echo "[:-] prepare to backup '${host}:${dir}' to tag '${tag}'"
	set +e
	exists=`ssh_exe "${host}" "test -d \"${dir}.${tag}\" && echo exists"`
	set -e
	if [ ! -z "${exists}" ]; then
		echo "[:(] '${host}:${dir}.${tag}' exists, backup failed"
		exit 1
	fi

	cmd="rm -rf \"${dir}.${tag}\" && rm -f \"${dir}/data/space_placeholder_file\" && cp -rp \"${dir}\" \"${dir}.${tag}\""
	echo + ssh -i "${pri_key}" -o BatchMode=yes "${user}"@"${host}" ${cmd}
	ssh_exe "${host}" "${cmd}"
done
