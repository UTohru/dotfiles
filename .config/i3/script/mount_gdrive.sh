#!/bin/bash

MNTDIR="${HOME}/mnt/gdrive"

if [ ! -d $MNTDIR ]; then
	mkdir -p $MNTDIR
fi

while true; do
  # check to see if there is a connection by pinging a Google server
  if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
    # if connected, mount the drive and break the loop
    mount | grep "${MNTDIR}" >/dev/null || /usr/bin/google-drive-ocamlfuse "${MNTDIR}"&
    break
  else
    # if not connected, wait for one second and then check again
    sleep 1
  fi
done
