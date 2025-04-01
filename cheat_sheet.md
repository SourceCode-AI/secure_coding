Reproducible builds exercise
============================

Reproducing a package ~ 20min

```shell
root@7ccad3d01d39:/# cd /local_data/python_package/

root@7ccad3d01d39:/secure_coding//python_package# ls
pyproject.toml  secure_coding_demo_package

root@7ccad3d01d39:/secure_coding/python_package# python3 -m build
...
Successfully built secure_coding_demo_package-0.0.1.tar.gz and secure_coding_demo_package-0.0.1-py3-none-any.whl


root@7ccad3d01d39:/secure_coding/python_package# diffoscope dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /secure_coding/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl

root@7ccad3d01d39:/secure_coding/python_package# mkdir /secure_coding/html
root@7ccad3d01d39:/secure_coding/python_package# diffoscope dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /secure_coding/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl --html-dir /local_data/html

root@7ccad3d01d39:/secure_coding/python_package# strip-nondeterminism dist/secure_coding_demo_package-0.0.1-py3-none-any.whl
root@7ccad3d01d39:/secure_coding/python_package# diffoscope dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /local_data/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl
root@7ccad3d01d39:/secure_coding/python_package# md5sum dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /local_data/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl

e11a303eef41e70032b4130652e740be  dist/secure_coding_demo_package-0.0.1-py3-none-any.whl
e11a303eef41e70032b4130652e740be  /secure_coding/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl
```


compare compiled code ~5 min
```shell
root@8157f590f783:/# cd /local_data/
root@8157f590f783:/local_data# diff hello_world.c malwaretest.c
4c4
< 	printf("Hello world\n");
---
> 	printf("malwaretest\n");


gcc hello_world.c -o a.out
gcc malwaretest.c -o b.out

diffoscope a.out b.out

```

CTX Malware exercise ~ 15 min


Vault
=====

Vault KV
--------

~ 15 mins

```bash
# verify creds
vault status
vault login

# Store secret
vault kv put -mount=secret secure_coding my_key=my_value
# Retrieve secret
vault kv get -mount=secret secure_coding

# overwrite

vault kv put -mount=secret secure_coding key2=value2
# fetch again via kv get

# get previous version
vault kv get -mount=secret -version=1 secure_coding

# delete a secret
vault kv delete -mount=secret secure_coding

# Rollback to version .1
vault kv rollback -mount secret -version=1 secure_coding

# Get json format
vault kv get -mount=secret -format=json secure_coding

# Show HTTP request
vault kv get -output-curl-string  -mount=secret -format=json secure_coding
apk add curl
# Issue curl HTTP api request
curl -H "X-Vault-Request: true" -H "X-Vault-Token: $(vault print token)" http://127.0.0.1:8200/v1/secret/data/secure_coding
```



Vault PostgresQL Integration
============================

~ 20 min

Setup DB
```shell
root@debian12:~# sudo -u postgres psql -c "create role vault with login superuser password 'insecure'";
could not change directory to "/root": Permission denied
CREATE ROLE

root@debian12:~# psql --user vault --password --host 172.26.7.80 --db secure_db
Password:
psql (15.12 (Debian 15.12-0+deb12u2))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
Type "help" for help.

secure_db=# create table users (name VARCHAR(255));
CREATE TABLE
secure_db=# insert into users values ('john doe');
INSERT 0 1
secure_db=# select * from users;
   name
----------
 john doe
(1 row)

secure_db=# exit
```

Configure vault
```shell
/ # vault secrets enable database
Success! Enabled the database secrets engine at: database/

# Configure the connection to postgres

/ # vault write database/config/secure_db \
 plugin_name="postgresql-database-plugin" \
 allowed_roles="secure_coding_role" \
 connection_url="postgresql://{{username}}:{{password}}@<YOUR_IP>:5432/secure_db?sslmode=disable" \
 username="vault" \
 password="not_so_secure_default_password"
Success! Data written to: database/config/secure_db

/ # vault write database/roles/secure_coding_role \
 db_name="secure_db" \
 creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
 GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; " \
 default_ttl="1h" \
 max_ttl="24h"
Success! Data written to: database/roles/secure_coding_role

# Get credentials
/ # vault read database/creds/secure_coding_role

/ # psql -h postgres -d secure_data -U <username>

secure_data=> SELECT * FROM users;
 name
------
(0 rows)

secure_data=> INSERT INTO users VALUES ('ratata');
ERROR:  permission denied for table users
```

