# https://earthly.dev/blog/set-up-postgresql-db/

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


# master slave data backup and replica data create 
sudo pg_basebackup -h 0.0.0.0 -p 5432 -D /tmp/lib/postgres_data_backup -U replica -P -v
sudo docker exec -it primary_db pg_basebackup -h 0.0.0.0 -p 5432 -D /postgres_data_backup -U replica -P -v
docker inspect primary_db # try to find given information for postgres_secondary folder
"MergedDir": "/var/lib/docker/overlay2/4673d08e57f317c8e7bea848053f3acec46e0197d90b3895295c1d7e8e88bb74/merged"
/var/lib/docker/overlay2/4673d08e57f317c8e7bea848053f3acec46e0197d90b3895295c1d7e8e88bb74/merged/postgres_data_backup/

# add this information
$(pwd)/postgres_data_backup/postgresql.conf
primary_conninfo = 'host=db port=5432 user=replica password=replica'
hot_standby = on

mkdir $(pwd)/postgres_data_backup/standby.signal

cp -r $(pwd)/postgres_data_backup $(pwd)/replica0_data
cp -r $(pwd)/postgres_data_backup $(pwd)/replica1_data
cp -r $(pwd)/postgres_data_backup $(pwd)/replica2_data

# for secondary database
docker run --restart always --name secondary_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
 $(pwd)/replica0_data:/var/lib/postgresql/data --link primary_db:db -p 5433:5432 -d postgis/postgis:latest

psql 'postgres://postgres:1234@0.0.0.0:5433/postgres?sslmode=disable'

# for primary_db this command is very important for replica
psql 'postgres://postgres:1234@0.0.0.0:5432/postgres?sslmode=disable'
CREATE DATABASE primary_db; 
\c primary_db
SELECT * FROM pg_create_physical_replication_slot ('standby_replication_slot');

# add $(pwd)/replica0_data/postgresql.conf
# this line will be run after docker run cmd
primary_slot_name = 'standby_replication_slot'

docker restart secondary_db



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



# for third_db 
/tmp/lib/postgres_third/postgresql.conf
primary_conninfo = 'host=db port=5432 user=replica password=replica'
hot_standby = on

sudo mkdir /tmp/lib/postgres_third/standby.signal

docker run --restart always --name third_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
 $(pwd)/replica1_data:/var/lib/postgresql/data --link primary_db:db -p 5434:5432 -d postgis/postgis:latest

psql 'postgres://postgres:1234@0.0.0.0:5434/postgres?sslmode=disable'

# primary_db
psql 'postgres://postgres:1234@0.0.0.0:5432/primary_db?sslmode=disable'
SELECT * FROM pg_create_physical_replication_slot ('standby_replication_slot_third');

# add /tmp/lib/postgres_third/postgresql.conf
# this line will be run after docker run cmd
primary_slot_name = 'standby_replication_slot_third'

docker restart third_db






# for fourth_db 
/tmp/lib/postgres_fourth/postgresql.conf
primary_conninfo = 'host=db port=5432 user=replica password=replica'
hot_standby = on

sudo mkdir /tmp/lib/postgres_fourth/standby.signal


docker run --restart always --name fourth_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=1234  -v \
 $(pwd)/replica2_data:/var/lib/postgresql/data --link primary_db:db -p 5435:5432 -d postgis/postgis:latest

psql 'postgres://postgres:1234@0.0.0.0:5435/postgres?sslmode=disable'

# primary_db
psql 'postgres://postgres:1234@0.0.0.0:5432/primary_db?sslmode=disable'
SELECT * FROM pg_create_physical_replication_slot ('standby_replication_slot_fourth');

# add /tmp/lib/postgres_fourth/postgresql.conf
# this line will be run after docker run cmd
primary_slot_name = 'standby_replication_slot_fourth'

docker restart fourth_db




# for primary_db
psql 'postgres://postgres:1234@0.0.0.0:5432/primary_db?sslmode=disable'


# for replica
psql 'postgres://postgres:1234@0.0.0.0:5433/primary_db?sslmode=disable'
psql 'postgres://postgres:1234@0.0.0.0:5434/primary_db?sslmode=disable'
psql 'postgres://postgres:1234@0.0.0.0:5435/primary_db?sslmode=disable'




docker restart primary_db
docker restart secondary_db
docker restart third_db
docker restart fourth_db


sudo docker update --restart always fourth_db third_db secondary_db primary_db
sudo docker stop fourth_db third_db secondary_db primary_db




###################################################################
sudo pacman -Sy
sudo pacman -S postgresql gambas3-gb-db-postgresql	

ss -tunelp | grep 5432

su
su postgres
initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'


sudo systemctl enable postgresql
sudo systemctl restart postgresql

locate psql
sudo -u postgres psql
sudo -u postgres /opt/PostgreSQL/10/bin/psql -p 5439
sudo -u postgres psql -p 5439

sudo nano /var/lib/postgres/data/postgresql.conf

