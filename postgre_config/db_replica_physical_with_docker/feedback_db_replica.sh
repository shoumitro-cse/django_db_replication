# for master slave postgresql database (postgresql version 15). It's a physical database
sudo -u postgres psql
CREATE USER replica REPLICATION LOGIN ENCRYPTED PASSWORD 'mektec_@1234';
# ALTER USER postgres WITH PASSWORD '1234';

sudo su
echo 'host replication replica  0.0.0.0/0 trust' >> /etc/postgresql/15/main/pg_hba.conf
exit
# nano editor use ctrl + w = text searching
sudo nano /etc/postgresql/15/main/postgresql.conf
wal_level = replica
max_wal_senders =  10 #How many secondaries can connect 
sudo systemctl restart postgresql

sudo -u postgres psql
SELECT * FROM pg_stat_replication;
CREATE TABLE student(
   ID             INT   ,
   NAME           TEXT ,
   AGE            INT ,
   ADDRESS        CHAR(50)
);
insert into student(id,name,age,address) values(100,'Shoumitro Roy','23','Jessore'); 
select * from student;


# for slave replica0
# cp -r  /home/ubuntu/postgres_setup/postgres_base_backup/  /home/ubuntu/postgres_setup/postgres_replica0
pg_basebackup -h 35.212.212.164 -p 5432 -D /home/ubuntu/postgres_setup/postgres_replica0 -U replica -P -v 
cd postgres_replica0
nano postgresql.conf
nano pg_hba.conf
nano pg_ident.conf
# add this information. nano editor use ctrl + w = text searching
nano postgresql.conf
primary_conninfo = 'host=35.212.212.164 port=5432 user=replica password=mektec_@1234'
hot_standby = on
mkdir standby.signal
cd ..

sudo docker run --restart always --name replica0_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
/home/ubuntu/postgres_setup/postgres_replica0:/var/lib/postgresql/data -p 5433:5432 -it postgres:15.1
sudo docker update --restart always replica0_db

sudo docker restart replica0_db
psql 'postgres://postgres:1234@0.0.0.0:5433/feedback_testing?sslmode=disable'
\c feedback_testing
select * from newsfeed_userposts;
# this con't works here
insert into student(id,name,age,address) values(100,'Shoumitro Roy','23','Jessore');  



# for slave replica1
pg_basebackup -h 35.212.212.164 -p 5432 -D /home/ubuntu/postgres_setup/postgres_replica1 -U replica -P -v 
cd postgres_replica1
nano postgresql.conf
nano pg_hba.conf
nano pg_ident.conf
# add this information. nano editor use ctrl + w = text searching
nano postgresql.conf
primary_conninfo = 'host=35.212.212.164 port=5432 user=replica password=mektec_@1234'
hot_standby = on
mkdir standby.signal
cd ..

sudo docker run --restart always --name replica1_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
/home/ubuntu/postgres_setup/postgres_replica1:/var/lib/postgresql/data -p 5434:5432 -it postgres:15.1
sudo docker restart replica1_db
psql 'postgres://postgres:1234@0.0.0.0:5434/feedback_testing?sslmode=disable'
psql -h localhost -p 5432 -U postgres



# for slave replica2
pg_basebackup -h 35.212.212.164 -p 5432 -D /home/ubuntu/postgres_setup/postgres_replica2 -U replica -P -v 
cd postgres_replica2
nano postgresql.conf
nano pg_hba.conf
nano pg_ident.conf
# add this information. nano editor use ctrl + w = text searching
nano postgresql.conf
primary_conninfo = 'host=35.212.212.164 port=5432 user=replica password=mektec_@1234'
hot_standby = on
mkdir standby.signal
cd ..

sudo docker run --restart always --name replica2_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
/home/ubuntu/postgres_setup/postgres_replica2:/var/lib/postgresql/data -p 5435:5432 -it postgres:15.1
sudo docker restart replica2_db
psql 'postgres://postgres:1234@0.0.0.0:5435/feedback_testing?sslmode=disable'
psql -h localhost -p 5432 -U postgres




# for postgres base backup
cd /home/ubuntu/postgres_setup/postgres_base_backup/
pg_basebackup -h 35.212.212.164 -p 5432 -D /home/ubuntu/postgres_setup/postgres_base_backup -U replica -P -v


/home/ubuntu/postgres_setup/postgres_base_backup/postgresql.conf
primary_conninfo = 'host=35.212.212.164 port=5432 user=replica password=mektec_@1234'
hot_standby = on

mkdir standby.signal



# postgres server backup
pg_basebackup -h 35.212.212.164 -p 5432 -D /fb_data -U replica -P -v
sudo docker exec -it primary_db pg_basebackup -h 0.0.0.0 -p 5432 -D /fb_p_data -U replica -P -v
pw: mektec_@1234
docker inspect primary_db # find for fb_p_data folder

# must create this dir
mkdir $(pwd)/fb_data/standby.signal

# for primary or replica both must use it
sudo nano $(pwd)/fb_data/postgresql.conf
wal_level = replica
max_wal_senders =  10 #How many secondaries can connect 


# it's only for standby or replica database and must comment for primary database
nano ./fb_p_data/postgresql.conf
primary_conninfo = 'host=db port=5432 user=replica password=mektec_@1234'
hot_standby = on			# "off" disallows queries during recovery

# for replica data
cp -r $(pwd)/fb_data $(pwd)/replica0_data
cp -r $(pwd)/fb_data $(pwd)/replica1_data
cp -r $(pwd)/fb_data $(pwd)/replica2_data

docker run --restart always --name primary_db  -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234 \
-v  $(pwd)/fb_data:/var/lib/postgresql/data -d postgis/postgis:latest

docker run --restart always --name primary_db  -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234 \
-v  $(pwd)/fb_data:/var/lib/postgresql/data -it postgis/postgis:latest

docker run --restart always --name secondary_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
 $(pwd)/replica0_data:/var/lib/postgresql/data --link primary_db:db -p 5433:5432 -d postgis/postgis:latest
 
docker run --restart always --name third_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
 $(pwd)/replica1_data:/var/lib/postgresql/data --link primary_db:db -p 5434:5432 -d postgis/postgis:latest
 
docker run --restart always --name fourth_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
 $(pwd)/replica2_data:/var/lib/postgresql/data --link primary_db:db -p 5435:5432 -d postgis/postgis:latest


psql 'postgres://postgres:1234@0.0.0.0:5432/postgres?sslmode=disable'
psql -h 0.0.0.0 -p 5432 -U postgres


sudo docker stop primary_db fourth_db third_db secondary_db 
sudo docker rm primary_db fourth_db third_db secondary_db
sudo docker restart primary_db fourth_db third_db secondary_db


# for primary db
SELECT * FROM pg_stat_replication;
CREATE TABLE student(
   ID             INT   ,
   NAME           TEXT ,
   AGE            INT ,
   ADDRESS        CHAR(50)
);
insert into student(id,name,age,address) values(100,'Shoumitro Roy','23','Jessore'); 
select * from student;
select count(*) from student;



# for primary_db
psql 'postgres://postgres:1234@0.0.0.0:5432/postgres?sslmode=disable'


# for replica
psql 'postgres://postgres:1234@0.0.0.0:5433/postgres?sslmode=disable'
psql 'postgres://postgres:1234@0.0.0.0:5434/postgres?sslmode=disable'
psql 'postgres://postgres:1234@0.0.0.0:5435/postgres?sslmode=disable'






# it's can't primary database this like
# for master primary database
docker run --restart always --name primary_db  -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234 \
-v  $(pwd)/postgres_data:/var/lib/postgresql/data -d postgis/postgis:latest

# error: Be careful: removing "/var/lib/postgresql/data/backup_label" will result in a corrupt cluster if restoring from a backup.
sudo rm $(pwd)/postgres_data/backup_label

# add this line of code last of the file.
sudo nano $(pwd)/postgres_data/pg_hba.conf
host replication replica  0.0.0.0/0 trust
# or
echo 'host replication replica  0.0.0.0/0 trust' >> $(pwd)/postgres_data/pg_hba.conf

docker exec -it primary_db bash
psql -h 0.0.0.0 -p 5432 -U postgres
CREATE USER replica REPLICATION LOGIN ENCRYPTED PASSWORD 'replica';
ALTER USER postgres WITH PASSWORD '1234';
psql 'postgres://postgres:1234@0.0.0.0:5432/postgres?sslmode=disable'

sudo nano $(pwd)/postgres_data/postgresql.conf
wal_level = replica
max_wal_senders =  10 #How many secondaries can connect 
docker restart primary_db

