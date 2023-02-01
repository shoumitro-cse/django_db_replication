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
