#! /bin/bash

#Copyright (c) 2014, Nikos Papakonstantinou <npapak@gmail.com>
#All rights reserved.

#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# * Neither the name of the <organization> nor the
#   names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
#DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#Usage

#backup_script
#=============

#Change the <user> with yout username.
#Change the <path for backup> with the path which you want to backup.
#Change the <backup directory name> with the directory for backup.
#Change the <path for saving backup> with the directory in which you want to save
#the backup_script.
#Change the <path for logfile> with the path you want to save the backup logfile.

#You have to gine execute pemissions tou script file if you want to use it.
#You can use cron or cron_tab for autorun the script once a day for example.

# Variables
location=/home/<user>/<path for backup> 
directory=<backup directory>
backuplocation=/home/<user>/<path for saving backup>
log=/home/<user>/<path for logfile>/backup.log
yesterday=`date -d '1 day ago' +'%y%m%d'`

echo -e “\nBackup started: `date`” >> $log
if [ -d $backuplocation ]; then

mkdir -p $backuplocation/`date +%y%m%d`
cd $location
tar -cvvf $backuplocation/`date +%y%m%d`/data.`date +%H%M%S`.tar.gz $directory
chown npapak:npapak *.*
rm -fr $backuplocation/$yesterday

echo ” completed: `date`” >> $log
echo ” user: `whoami`” >> $log
echo -e “\n — Backup completed –\n”;
else
echo ” FAILED: `date`” >> $log
echo -e “\n– WARNING: –”
echo -e “– BACKUP FAILED –\n”;
fi

