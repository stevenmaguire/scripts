# scripts
sometimes i tell computers what to do

## s3mysqlbackup.sh

Ensure the machine has `curl` [s3cmd tools](http://s3tools.org/s3cmd) installed and that you've configured `s3cmd --configure`.

Configure a cron job to run the following:

```bash
bash <(curl -s https://raw.githubusercontent.com/stevenmaguire/scripts/master/s3mysqlbackup.sh) -u YOUR_MYSQL_USER -p YOUR_MYSQL_PASSWORD -b YOUR_BUCKET_NAME
```

For each of the databases the user has access, the job will backup and compress the data into temporary files, upload those files to your s3 bucket, and remove the local temporary file. 

The job will create a folder system in your bucket organized by machine name and timestamp.

```bash
machine1.name
  - YYYY-MM-DD@HHMM
    - database1.sql.gz
    - database2.sql.gz
  - YYYY-MM-DD@HHMM
    - database1.sql.gz
    - database2.sql.gz    
machine2.name
  - YYYY-MM-DD@HHMM
    - database1.sql.gz
    - database2.sql.gz
  - YYYY-MM-DD@HHMM
    - database1.sql.gz
    - database2.sql.gz
```
