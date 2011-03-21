#!/bin/bash                                                                                                                                             

# Backup mysql databases.

# Check to see if mysqld is running.
if ps ax | grep -v grep | grep mysqld > /dev/null
	then
		# Set a value that we can use for a datestamp
		DATE=`date +%Y-%m-%d-%H%M%S`                                                                                                                                            
		# Our Base backup directory
		BASEBACKUP="."

		for DATABASE in `echo 'show databases' | mysql --column-names=false -uroot -proot`
		do
        	# This is where we throw our backups.
        	FILEDIR="$BASEBACKUP/$DATABASE"

        	# Test to see if our backup directory exists. 
        	# If not, create it.
        	if [ ! -d $FILEDIR ]
        		then
              		mkdir -p $FILEDIR
       		fi

       		echo -n "Exporting database:  $DATABASE"
       		mysqldump --host=localhost --user=root --password=root --single-transaction --opt $DATABASE | gzip -c -9 > $FILEDIR/$DATABASE-$DATE.sql.gz
       		echo "      ......[ Done ] "
		done
fi
	
# AutoPrune our backups.  This will find all files
# that are "MaxFileAge" days old and delete them.
MaxFileAge=3
find $BASEBACKUP -name '*.gz' -type f -mtime +$MaxFileAge -exec rm -f {} \; 
