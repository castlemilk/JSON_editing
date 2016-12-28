#!/bin/bash
# basic script to initialise SSH configuration and establish
# connetion to the remote mongoDB database containing the 
# food records for editing.


USER = ${USER:-"editor"}
PASSWD = ${PASSWD}
DEST = ${DEST}
HOSTNAME = ${HOSTNAME:-"editor"}
KEY_DEST = ${KEY_DEST:-"~/.ssh/id_rsa"}

function conf_hosts()
{
	echo "${DEST}	${HOSTNAME}" >> /etc/hosts
}

function conf_SSH()
{
	echo "Host ${HOSTNAME}
	Hostname ${HOSTNAME}
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
	ssh-copy-id ${HOSTNAME}
}

function connect()
{
	ssh -N -L 27017:localhost:27017 ${HOSTNAME} &	
	echo "Connection should be established. Now try"
	echo " connect on localhost:27017 in Robomongo"
}


if ! grep -Fqx ".*${HOSTNAME}" /etc/hosts; then
	conf_host
fi
if [ -v ${KEY_DEST} ]; then
	create_key
fi
if ! grep -Fqx "Host ${HOSTNAME}" ~/.ssh/config; then
	conf_SSH
	copy_ssh_id
fi


