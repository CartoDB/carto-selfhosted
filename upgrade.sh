#!/bin/sh
set -e

ORG_FILE='.env'
RECORD_FILE=$(date '+%Y%m%d')
RECORD_FOLDER='PAST_ENV'

cp -R $ORG_FILE $RECORD_FILE

echo $RECORD_FILE

if [ -d $RECORD_FOLDER ] 
then
	mv $RECORD_FILE $RECORD_FOLDER
	echo "$ORG_FILE recorded in $RECORD_FOLDER"
else
	mkdir $RECORD_FOLDER
	mv $RECORD_FILE $RECORD_FOLDER
    echo "$ORG_FILE recorded in $RECORD_FOLDER"
fi

git pull

./install.sh

docker-compose up -d

echo "Upgrade Complete"
