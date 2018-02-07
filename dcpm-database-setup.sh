#! /bin/bash

## this script for database machine which use postqres
## pleas put first input is the ip range of dcpm network assumed that is /24 network
pg_hba=`find /etc -name pg_hba.conf  2>/dev/null`
postconfig=`find /etc -name postgresql.conf  2>/dev/null`
apt-get -y update
apt -y autoremove
apt-get install -y postgresql
if grep $1 $pg_hba 2>/dev/null ; then
	echo "the ip range already exist, please check the pg_hba.conf configuration file"
else 

	echo -e "host\tall\t\tall\t$1/24\t\tmd5" >> $pg_hba

fi

if grep -v "^#" $postconfig | grep "listen_addresses = '*'" 2>/dev/null ; then
	echo "the configuration already exist, Please check the postgresql.conf configuration file"
else
	echo "listen_addresses = '*' ">> $postconfig
fi

echo "Restarting postgres .................................."
service postgresql restart
systemctl enable postgresql


cat << EOF > /tmp/dcpm.sql
Create database dcpm_db;
Create database dcpm_mon;

Create user dcpm with password '1234';

Grant all on database dcpm_db to dcpm;
Grant all on database dcpm_mon to dcpm;
Alter database dcpm_db owner to dcpm;
Alter database dcpm_mon owner to dcpm;

ALTER DATABASE dcpm_db SET bytea_output = 'escape';
EOF
### show database 
cat << EFO > /tmp/showdatabase.sql
\l
EFO

if su - postgres -c "psql < /tmp/showdatabase.sql" | grep  dcpm_mon > /dev/null ; then

        echo "database already exist, No change on database"
else

        echo "database does not exist , create new one"
        su - postgres -c "psql < /tmp/dcpm.sql"
fi

echo " verify the database was created successfully "

su - postgres -c "psql < /tmp/showdatabase.sql"

