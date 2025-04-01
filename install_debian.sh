#!/bin/bash

cd /
apt-get update
apt-get install -y gpg

wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

apt-get update
apt-get install -y  nano gcc wget jq screen python3-venv python3-pip strip-nondeterminism tree postgresql postgresql-client vault git python3-pip xxd binutils-multiarch openssl

apt-get install -y diffoscope-minimal --no-install-suggests --no-install-recommends
pip install build==1.2.1 wheel==0.43.0 setuptools==61.0 --break-system-packages

git clone https://github.com/SourceCode-AI/secure_coding.git /secure_coding

echo "listen_addresses='*'">>/etc/postgresql/15/main/postgresql.conf

echo "host    all             all              0.0.0.0/0                       scram-sha-256">>/etc/postgresql/15/main/pg_hba.conf
echo "host    all             all              ::/0                            scram-sha-256">>/etc/postgresql/15/main/pg_hba.conf

#PG_PASSWD=$(openssl rand -hex 16)
sudo -u postgres createdb secure_db
sudo -u postgres psql -c "create role vault with login superuser password 'not_so_secure_default_password'";
sudo -u postgres psql -c --db secure_db "create table users (name VARCHAR(255));";
sudo -u postgres psql -c --db secure_db "insert into users values ('john doe');";
systemctl restart postgresql

#pip3 install build --break-system-packages
echo "export VAULT_SKIP_VERIFY=true">>/etc/bash.bashrc
echo "export VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200">>/etc/bash.bashrc
echo "export VAULT_ADDR=http://127.0.0.1:8200">>/etc/bash.bashrc
touch /tmp/automation_finished
