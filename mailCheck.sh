#!/bin/bash

if [ -r "$HOME/.dbus/Xdbus" ]; then
	. "$HOME/.dbus/Xdbus"
fi
mkdir -p ~/.mail
timeout 100s /usr/bin/mbsync -aV > ~/.mail/mail.log
for folder in 'INBOX' 'Work' 'Personal'; #Folders to be check for new e-mails
do
	master=`grep -A4 "$folder\.\.\." ~/.mail/mail.log | tail -2 | cut -f2 -d" " | sed -n '2p'`
	master_recent=`grep -A4 "$folder\.\.\." ~/.mail/mail.log | tail -2 | cut -f4 -d" " | sed -n '2p'`
	slave=`grep -A4 "$folder\.\.\." ~/.mail/mail.log | tail -2 | cut -f2 -d" " | sed -n '1p'`
	slave_recent=`grep -A4 "$folder\.\.\." ~/.mail/mail.log | tail -2 | cut -f4 -d" " | sed -n '1p'`
	totalmail=$((master + master_recent - slave + slave_recent))
	if [ $totalmail -gt 0 ]; then
		/usr/bin/notify-send -i applications-email-panel E-mail "You've got $totalmail new e-mail(s) in folder $folder"
	fi
done
