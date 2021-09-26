#!/bin/sh
# 
#

# backup oracle info
export NLS_LANG="SIMPLIFIED CHINESE.ZHS16GBK"
oracle_user=oracle
backup_sid=dev2
backup_user=csp
backup_password=csp
backup_date=$(date +%Y%m%d)
backup_file="$backup_user"_"$backup_date".dmp
backup_tar_file=$backup_file.tar.gz
directory=dumpfiles
directory_path=/data/backup/dumpfiles

# remote server 
remote_ip=192.168.1.194
remote_port=22
remote_backup_path=/data/backup/csp_11_db

# expdp backup user data
su -c "expdp $backup_user/$backup_password@$backup_sid schemas=$backup_user directory=$directory dumpfile=$backup_file logfile='$backup_user'_'$backup_date'.log" $oracle_user

# tar backup dump file and copy to remote server
tar -zcf "$directory_path/$backup_tar_file" -C $directory_path $backup_file
scp -P $remote_port $directory_path/$backup_tar_file root@$remote_ip:$remote_backup_path

# delete remote server  before 30 old days files
ssh -p $remote_port root@$remote_ip "find $remote_backup_path -type f -mtime +30 -exec rm {} \; > /dev/null 2>&1"

# delete local before 7 old days files
find $directory_path -type f -mtime +7 -exec rm {} \; > /dev/null 2>&1
