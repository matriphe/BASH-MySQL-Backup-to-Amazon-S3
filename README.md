<h1>BASH MySQL Backup to Amazon S3</h1>
BASH script for back up MySQL database to Amazon S3. Simply run `db.backup.sh` from BASH shell. If want to backup all database, just run `all.db.backup.sh`. Make sure the user have privileges to lock tables.

<h2>Requirement</h2>

You need to install <a href="http://s3tools.org/s3cmd">S3CMD</a> tools for sending files to Amazon S3.