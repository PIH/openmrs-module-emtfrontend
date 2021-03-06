#!/bin/bash

INSTALL_DIR=$HOME/EmrMonitoringTool
LOG=$HOME/emt.log
CONFIG=$HOME/emt.properties
SYSTEM_ID=`hostname`-`ifconfig eth0 | grep HWaddr | awk '{ print $NF}' | sed 's/://g'`
NOW=`date +%Y%m%d-%H%M%S`

# make sure EMT is installed under user hc-admin (required by OpenMRS EMT Frontend module)
USER=`whoami`
if [ "$USER" != "hc-admin" ]; then
  echo ""
  echo "ERROR: EMT needs to be installed under user hc-admin. Please change user and install again."
  echo "       (This is required by the OpenMRS module EMT Frontend)"
  exit 1 
fi

# remove old cronjobs
crontab -l | grep -v heartbeat.sh | crontab -
crontab -l | grep -v openmrs-heartbeat.sh | crontab -
crontab -l | grep -v startup-hook.sh | crontab -

(crontab -l ; echo "1,16,31,46 * * * * $INSTALL_DIR/heartbeat.sh") | crontab -
(crontab -l ; echo "2,17,32,47 * * * * $INSTALL_DIR/openmrs-heartbeat.sh") | crontab -
(crontab -l ; echo "@reboot $INSTALL_DIR/startup-hook.sh") | crontab -

echo "$NOW;$SYSTEM_ID;EMT-INSTALL;0.5" >> $LOG

# create properties file if necessary
if [[ ! -f $CONFIG ]]; then
  echo ""
  echo "Creating default config file for clinic times"
  echo "clinicStart=800" >> $CONFIG
  echo "clinicEnd=1700" >> $CONFIG
  echo "clinicDays=Mo,Tu,We,Th,Fr" >> $CONFIG
fi
chmod 666 $CONFIG

# Check system time
echo ""
echo "ATTENTION: Please check the date and time of this system!"
echo "           Current date and time are: `date`"
echo ""
echo "           If this does NOT match the current real time, please report this!"
echo "           (Any difference of more than 5 minutes)"

# Check write permission for tomcat6 in modules directory
MODULES_OWNER=`stat -c '%U' /usr/share/tomcat6/.OpenMRS/modules | tail`
if [ "$MODULES_OWNER" != "tomcat6" ]; then
  echo ""
  echo "WARNING: OpenMRS modules most likely can NOT be uploaded with OpenMRS!" 
fi
