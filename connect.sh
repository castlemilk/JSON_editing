#!/bin/bash
# basic script to initialise SSH configuration and establish
# connetion to the remote mongoDB database containing the 
# food records for editing.


USER=${USER:-editor}
PASSWD=${PASSWD}
RDEST=${RDEST:-"128.199.230.194"}
RHOST=${RHOST:-editor}
KEY_DEST=${KEY_DEST:-~/.ssh/id_rsa}

function conf_hosts()
{
	echo "${RDEST}	${RHOST}" >> /etc/hosts
}

function conf_SSH()
{
	echo "Host ${RHOST}
	Hostname ${RHOST}
	User ${USER}
	IdentityFile ${KEY_DEST}.pub" >> ~/.ssh/config	
}
function create_key()
{
	ssh-keygen -f ${KEY_DEST} -q -N ""
	ssh-add ${KEY_DEST}
}
function copy_ssh_id()
{
	ssh-copy-id ${RHOST}
}

function connect()
{
	ssh -N -L 27017:localhost:27017 ${RHOST} &	
	echo "Connection should be established. Now try"
	echo " connect on localhost:27017 in Robomongo"
}


if ! grep -Fqx "^.*${RHOST}" /etc/hosts; then
	echo "adding configuration to host file"
	conf_hosts
fi
if [ ! -f ${KEY_DEST} ]; then
	echo "creating ssh key"
	create_key
fi
if ! grep -Fqx "Host ${RHOST}" ~/.ssh/config; then
	echo "configuring SSH"
	conf_SSH
	echo "copying SSH key to remote host"
	copy_ssh_id
fi

current_connection_process=`ps -ax | grep ssh | grep '27017:localhost' | awk '{print $1}'`
if [ -n "$current_connection_process" ]; then
	for process in $current_connection_process; do
		echo "found running tunnel with PID $process"
		echo "killing now"
		kill -9 $process
		echo "done"
	done
else
	connect
fi

