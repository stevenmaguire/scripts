#!/bin/bash

# Based on https://gist.github.com/2206527
# Forked from https://gist.github.com/oodavid/2206527

# Get some input
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -u|--user)
    MYSQL_USER="$2"
    shift # past argument
    ;;
    -p|--password)
    MYSQL_PASSWORD="$2"
    shift # past argument
    ;;
    -b|--bucket)
    S3_BUCKET="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

if [[ -z $MYSQL_USER || -z $MYSQL_PASSWORD || -z $S3_BUCKET ]]; then
  echo 'One or more variables are undefined. You need them all!'
  exit 1
fi
# We've got everythign we need

# Be pretty
echo -e " "
echo -e " .  ____  .    ______________________________"
echo -e " |/      \|   |                              |"
echo -e "[| ♥    ♥ |]  |    S3 MySQL Backup Script    |"
echo -e " |___==___|  /                               |"
echo -e "              |______________________________|"
echo -e " "


# Timestamp (sortable AND readable)
stamp=`date +"%F@%H%M"`

# List all the databases
databases=`MYSQL_PWD=$MYSQL_PASSWORD mysql -u $MYSQL_USER -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\)"`

# Feedback
echo -e "Dumping to $S3_BUCKET/$stamp/"

# Loop the databases
for db in $databases; do

  # Define our filenames
  filename="$db.sql.gz"
  tmpfile="/tmp/$stamp - $filename"
  object="$S3_BUCKET/$stamp/$filename"

  # Feedback
  total_length=70
  db_length=${#db}
  delta_length=$(($total_length - $db_length))
  echo -n "Starting: $db"
  head -c "$delta_length" < /dev/zero | tr '\0' '-'
  echo -e "\n"


  # # Dump and zip
  echo -e "Creating: $tmpfile \n"
  MYSQL_PWD=$MYSQL_PASSWORD mysqldump -u $MYSQL_USER --force --opt --databases "$db" | gzip -c > "$tmpfile"

  # # Upload
  echo -e "Uploading: s3://$object \n"
  s3cmd -m application/javascript --add-header='Content-Encoding: gzip' put "$tmpfile" "s3://$object"

  # # Delete
  rm -f "$tmpfile"

done;

# Jobs a goodun
echo -e "Jobs a goodun"
