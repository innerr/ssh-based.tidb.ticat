. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/ticat.helper.bash/helper.bash"

# export: $pri_key, $user, $cnt, $hosts, $dirs
function get_instance_info()
{
	local env="${1}"
	local check_stopped="${2}"

	local name=`must_env_val "${env}" 'tidb.cluster'`

	set +e
	local statuses=`tiup cluster display "${name}" 2>/dev/null`
	set -e
	local instances=`echo "${statuses}" | awk '{if ($2=="pd" || $2=="tikv" || $2=="tiflash" || $2=="tiflash-learner") print $0}'`
	if [ -z "${instances}" ]; then
		tiup cluster display "${name}"
		echo "[:(] can't find storage instances (pd/tikv/tiflash)" >&2
		exit 1
	fi
	cnt=`echo "${instances}" | wc -l`

	# TODO: use this key for ssh
	set +e
	pri_key=`tiup cluster list 2>/dev/null | awk '{if ($1=="'${name}'") print $NF}'`
	set -e

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
