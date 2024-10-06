#Installing and Configuring ClamAV

#Update your package lists
apt-get update && apt-get upgrade -y

#Install ClamAV and its daemon
apt-get install clamav clamav-daemon -y

#To Update Virus Definitions, Stop the clamav-freshclam and clamav-daemon services and ensure ClamAV can detect the latest threats by updating its virus definitions:
systemctl stop clamav-freshclam.service && systemctl stop clamav-daemon.service && freshclam

#Start the clamav-freshclam and clamav-daemon services, then manually scan a directory for viruses and malware using the clamscan tool:
systemctl start clamav-freshclam.service && systemctl start clamav-daemon.service && clamscan -r /path/to/directory/to/scan

#Set up a cron job to automate regular scans. Edit the crontab with:
crontab -e
#Add this line at the end of the file to schedule a daily scan:
0 2 * * * /usr/bin/clamscan -r /path/to/directory/to/scan --log=/var/log/clamav/scan.log

#Installing and Configuring rkhunter

#Install rkhunter
apt-get install rkhunter

#Update rkhunter Database by editing the rkhunter.conf file and update the following:
  # * Change the value of the MIRRORS_MODE variable from 1 to 0.
  # * Change the value of the UPDATE_MIRRORS variable from 0 to 1.
  # * Change the value of the WEB_CMD variable from "/bin/false" to an empty string.
#Save the file and run the rkhunter update command:
rkhunter --update

#Perform an Initial System Scan by Run an initial scan to check for rootkits:
rkhunter --checkall

#Automate rkhunter Scans by automatically run rkhunter scans, add a cron job by editing the crontab:
crontab -e
#Add this line at the end of the file to schedule a daily scan:
0 3 * * * /usr/bin/rkhunter --checkall --cronjob --report-warnings-only

#Keep ClamAV and rkhunter Updated
systemctl stop clamav-freshclam.service && systemctl stop clamav-daemon.service && freshclam && sudo rkhunter --update
