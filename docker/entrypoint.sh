#!/bin/bash

set -eu

if [ "$#" -eq 0 ]
then
  exit
fi

# Ensure that the USERINFO env var is set. We expect it to
# be set with the output of id
if [ "${USERINFO:-}" == "" ]
then
	echo missing USERINFO value
	exit 1
fi

# Ensure we have /var/run/docker.sock so we can use the host
# docker instance
if [ ! -S /var/run/docker.sock ]
then
	echo "missing /var/run/docker.sock; did you forget to specify a bind mount?"
	exit 1
fi

if [ ! -d /workdir ]
then
	echo "missing /workdir; did you forget to specify a bind mount?"
	exit 1
fi

username="$(echo "$USERINFO" | cut -d ' ' -f 1 | sed -e 's/uid=\(.*\)(\(.*\))/\2/')"
uid="$(echo "$USERINFO" | cut -d ' ' -f 1 | sed -e 's/uid=\(.*\)(\(.*\))/\1/')"
groupname="$(echo "$USERINFO" | cut -d ' ' -f 2 | sed -e 's/gid=\(.*\)(\(.*\))/\2/')"
guid="$(echo "$USERINFO" | cut -d ' ' -f 2 | sed -e 's/gid=\(.*\)(\(.*\))/\1/')"

if [ "$username" == "" ] || [ "$uid" == "" ] || [ "$groupname" == "" ] || [ "$guid" == "" ]
then
	echo USERINFO did not contain parseable information
	exit 1
fi

if [ "$uid" == "0" ] || [ "$guid" == "0" ]
then
	echo "running with uid or guid 0 (root) not supported"
	exit 1
fi

# A group named groupname or with guid guid might already exist.
# If so, do some modifying to ensure things line up

agroupname="$(getent group $guid | cut -d : -f 1)"
aguid="$(getent group $groupname | cut -d : -f 3)"
if [ "$agroupname" != "$groupname" ] || [ "$aguid" != "$guid" ]
then
	# We don't have the all the group information lined up
	if [ "$aguid" != "" ] && [ "$agroupname" != "" ]
	then
		# But $guid and $groupname are both in use
		groupmod -n _$groupname $groupname
		groupmod -n $groupname $agroupname
	elif [ "$aguid" != "" ]
	then
		# $groupname is in use
		groupmod -g $guid $groupname
	elif [ "$agroupname" != "" ]
	then
		# $guid is in use
		groupmod -n $groupname $agroupname
	else
		# Neither guid nor groupname refer to any group
		groupadd -r -g $guid $groupname
	fi
fi

ausername="$(getent passwd $uid | cut -d : -f 1)"
auid="$(getent passwd $username | cut -d : -f 3)"
if [ "$ausername" != "$username" ] || [ "$auid" != "$uid" ]
then
	# We don't have the all the user information lined up
	if [ "$auid" != "" ] && [ "$ausername" != "" ]
	then
		# But $uid and $username are both in use
		usermod -l _$username $username
		usermod -l $username $ausername
	elif [ "$auid" != "" ]
	then
		# $username is in use
		usermod -u $uid $username
	elif [ "$ausername" != "" ]
	then
		# $uid is in use
		usermod -l $username $ausername
	else
		# Neither uid nor username refer to any user
		useradd -s /bin/bash -u $uid -m --no-log-init -r -g $guid $username
	fi
fi

# Ensure that the docker group has the same gid
# as the group that owns /var/run/docker.sock
aguid="$(stat -c "%g" /var/run/docker.sock)"
dguid="$(getent group docker | cut -d : -f 3)"
if [ "$aguid" != "$dguid" ]
then
	agroupname="$(getent group $aguid | cut -d : -f 1)"
	if [ "$agroupname" != "" ]
	then
		# Add the user to $agroupname
		usermod -aG $agroupname $username
	else
		# $aguid is not used. Switch docker group to use $aguid
		groupmod -g $aguid docker
	fi
fi

# Add user to sudo
usermod -aG docker $username
cat <<EOD > /etc/sudoers
$username  ALL=(ALL) NOPASSWD:ALL
EOD

# Create the home dir if it does not exist
mkdir -p /home/$username
cp /root/.bashrc /home/$username
cp /root/.profile /home/$username
chown -R $username:$groupname /home/$username
chmod 600 /home/$username/.bashrc /home/$username/.profile
export HOME=/home/$username
cd /workdir
exec setpriv --reuid $uid --regid $guid --init-groups "$@"
