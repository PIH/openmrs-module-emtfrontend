#!/bin/bash

PATH=$PATH:/usr/bin:/sbin
BASEDIR=$(dirname $0)

LOG=$HOME/emt.log

OPENMRS_PROP_FILE=/usr/share/tomcat6/.OpenMRS/openmrs-runtime.properties
# Check runtime properties file exists
if ! [ -e "$OPENMRS_PROP_FILE" ]; then
  echo "Specified OpenMRS runtime properties file does not exist"
  exit 1
fi

# Read properties from properties file
DB_USER=`sed '/^\#/d' "$OPENMRS_PROP_FILE" | grep 'connection.username' | tail -n 1 | cut -d "=" -f2-`
DB_PASS=`sed '/^\#/d' "$OPENMRS_PROP_FILE" | grep 'connection.password' | tail -n 1 | cut -d "=" -f2-`
DB_URL=`sed '/^\#/d' "$OPENMRS_PROP_FILE" | grep 'connection.url' | tail -n 1 | cut -d "=" -f2-`
OPENMRS_USER=`sed '/^\#/d' "$OPENMRS_PROP_FILE" | grep 'scheduler.username' | tail -n 1 | cut -d "=" -f2-`
OPENMRS_PASS==`sed '/^\#/d' "$OPENMRS_PROP_FILE" | grep 'scheduler.password' | tail -n 1 | cut -d "=" -f2-`

# Check properties could be read
if [ -z $DB_USER ] || [ -z $DB_PASS ] || [ -z $DB_URL ] || [ -z OPENMRS_USER ] || [ -z OPENMRS_PASS ]; then
  echo "Unable tp read OpenMRS runtime properties"
  exit 1
fi

# Extract database name from connection URL
if [[ $DB_URL =~ /([a-zA-Z0-9_\-]+)\? ]]; then
  DB_NAME=${BASH_REMATCH[1]}
else
  DB_NAME="openmrs"
fi

OPENMRS_URL=https://localhost/openmrs

SYSTEM_ID=`hostname`-`ifconfig eth0 | grep HWaddr | awk '{ print $NF}' | sed 's/://g'`
NOW=`date +%Y%m%d-%H%M%S`

# check Tomcat and OpenMRS webapp
wget --quiet --no-check-certificate --post-data "uname=$OPENMRS_USER&pw=$OPENMRS_PASS" $OPENMRS_URL/loginServlet
if [ $? -ne 0 ]; then
  # do it again to make sure this system wasn't just too busy in this moment
  sleep 60
  wget --quiet --no-check-certificate --post-data "uname=$OPENMRS_USER&pw=$OPENMRS_PASS" $OPENMRS_URL/loginServlet
  if [ $? -ne 0 ]; then
    OPENMRS_STATUS="not responding"
  else
    OPENMRS_STATUS="responding after 1 minute"
  fi
else
  OPENMRS_STATUS="responding"
fi
rm -f index.htm*
rm -f loginServlet*

# get encounter/obs stats right from DB
NUMBER_ENCOUNTERS=`mysql -u$DB_USER -p$DB_PASS $DB_NAME -s -N  -e "select count(*) from encounter where voided=0"`
NUMBER_OBS=`mysql -u$DB_USER -p$DB_PASS $DB_NAME -s -N  -e "select count(*) from obs where voided=0"`
NUMBER_USERS=`mysql -u$DB_USER -p$DB_PASS $DB_NAME -s -N -e "select count(*) from users where retired=0"`
MYSQL_STATUS="$NUMBER_ENCOUNTERS;$NUMBER_OBS;$NUMBER_USERS"

# backup status
BACKUP_STATUS=`ls -tr1 /var/backups/OpenMRS | tail -1`

# MoH data quality checks
NUMBER_ACTIVE_PATIENTS=`mysql -u$DB_USER -p$DB_PASS $DB_NAME -s -N -e "select count(distinct person_id) from obs o inner join patient_program pp on o.person_id = pp.patient_id inner join orders ord on o.person_id = ord.patient_id where o.concept_id = 1811 and program_id = 2 and ord.concept_id in (select distinct concept_id from concept_set where concept_set = 1085);"`
NUMBER_NEW_PATIENTS=`mysql -u$DB_USER -p$DB_PASS $DB_NAME -s -N -e "select count(*) from encounter where encounter_type in (1,3)"`
NUMBER_VISITS=`mysql -u$DB_USER -p$DB_PASS $DB_NAME -s -N -e "select count(*) from encounter where encounter_type in (2,4)"`
MOH_STATUS="$NUMBER_ACTIVE_PATIENTS;$NUMBER_NEW_PATIENTS;$NUMBER_VISITS"

echo "$NOW;$SYSTEM_ID;OPENMRS-HEARTBEAT;$OPENMRS_STATUS;$MYSQL_STATUS;$BACKUP_STATUS;$MOH_STATUS">> $LOG
