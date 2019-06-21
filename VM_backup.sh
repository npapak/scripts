#!/bin/bash

# Copyright (c) 2019, Nikos Papakonstantinou <npapak@gmail.com>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met :
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#   * Neither the name of any individual or organization nor the names of its
#     contributors may be used to endorse or promote products derived from this
#     software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# ( INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION ) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT ( INCLUDING NEGLIGENCE OR OTHERWISE ) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if [ "$#" -ne 1 ]; then
	echo "Please give the name of VM to backup"
	exit 0
fi

GUEST=$1

GUEST_LOCATION=`virsh domstats $GUEST | grep block.0.path | cut -d = -f2-`
if [[ -z $GUEST_LOCATION ]]; then
	echo "There is not VM with name $GUEST"
	exit 0
fi

BACKUP_LOCATION=/$GUEST\_backup
BLOCKDEVICE=`virsh domstats $GUEST | grep block.0.name | cut -d = -f2-`
DATE=`date +%F_%H-%M`
GUEST_SIZE=`du -sh $GUEST_LOCATION | awk '{ print $1 }'`

if [ `ls $GUEST_LOCATION | cut -d . -f2-|grep --count "qcow2"` -eq 0 ]; then
	echo "Image file for $GUEST not in qcow2 format."
	exit 0;
fi

if [ `virsh list | grep running | awk '{print $2}' | grep --count $GUEST` -eq 0 ]; then
	echo "$GUEST not active, skipping.."
	exit 0;
fi

if [ ! -d $BACKUP_LOCATION ];then
	mkdir -p $BACKUP_LOCATION;
fi
chown -R qemu:qemu $BACKUP_LOCATION

logger "Guest backup for $GUEST starting - current image size at $GUEST_SIZE"

virsh dumpxml --security-info $GUEST > $BACKUP_LOCATION/$GUEST-$DATE.xml

virsh undefine $GUEST > /dev/null 2>&1

virsh blockcopy $GUEST $BLOCKDEVICE $BACKUP_LOCATION/$GUEST-$DATE.qcow2 --wait --finish

virsh define $BACKUP_LOCATION/$GUEST-$DATE.xml > /dev/null 2>&1

md5sum $BACKUP_LOCATION/$GUEST-$DATE.qcow2 > $BACKUP_LOCATION/$GUEST-$DATE.sig

mkdir -p /Backup/$GUEST

tar cvfPJ /Backup/$GUEST/$GUEST-$DATE.xz $BACKUP_LOCATION

rm -fr $BACKUP_LOCATION

TOTAL_BACKUPS=`ls -l /Backup/$GUEST | sort -k1 | head -n -1 | wc -l`

if [ $TOTAL_BACKUPS -gt 5 ]; then
	REMOVE_BACKUP=`ls -l /Backup/$GUEST | sort -k1 | head -n -1 | tail -1 | awk '{print $9}'`
	rm -fr /Backup/$GUEST/$REMOVE_BACKUP
fi

logger "Guest backup for $GUEST done"

exit 0;
