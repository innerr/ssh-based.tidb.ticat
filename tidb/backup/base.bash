function ssh_exe()
{
	local host="${1}"
	local cmd="${2}"
	ssh -i "${pri_key}" -o BatchMode=yes "${user}"@"${host}" ${cmd} </dev/null
}

function env_val()
{
	local env="${1}"
	local key="${2}"

	local val=`echo "${env}" | { grep "^${key}" || test $? = 1; } | awk '{print $2}'`
	if [ -z "${val}" ]; then
		echo "[:(] no env val '${key}'" >&2
		exit 1
	fi
	echo "${val}"
}

# export: $pri_key, $user, $cnt, $hosts, $dirs
function get_instance_info()
{
	local env="${1}"
	local check_stopped="${2}"

	local name=`env_val "${env}" 'tidb.cluster'`

	local statuses=`tiup cluster display "${name}"`
	local instances=`echo "${statuses}" | awk '{if ($2=="pd" || $2=="tikv" || $2=="tiflash" || $2=="tiflash-learner") print $0}'`
	if [ -z "${instances}" ]; then
		echo "[:(] can't find pd or tikv instances" >&2
		exit 1
	fi
	cnt=`echo "${instances}" | wc -l`

	pri_key=`tiup cluster list | awk '{if ($1=="'${name}'") print $NF}'`

	# TODO: get this from tiup yaml file. and other values like ssh-port
	user='tidb'

	if [ "${check_stopped}" != 'false' ]; then
		local ups=`echo "${instances}" | awk '{print $6}' | { grep 'Up' || test $? = 1; }`
		if [ ! -z "${ups}" ]; then
			echo "[:(] cluster not fully stop, can't backup" >&2
			exit 1
		fi
	fi

	hosts=(`echo "${instances}" | awk '{print $3}'`)
	dirs=(`echo "${instances}" | awk '{print $NF}'`)

	if [ "${#hosts[@]}" != "${#hosts[@]}" ]; then
		echo "[:(] hosts count != dirs count, string parsing failed" >&2
		exit 1
	fi
	if [ "${#hosts[@]}" == '0' ]; then
		echo "[:(] hosts count == 0, string parsing failed" >&2
		exit 1
	fi
}

get_instance_info "${@}"
