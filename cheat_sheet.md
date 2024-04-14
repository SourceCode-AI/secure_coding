Reproducible builds exercise
============================

Reproducing a package ~ 20min

Exec inside the container `docker compose run --rm -ti secure_coding  /bin/bash`

```shell
root@7ccad3d01d39:/# cd /local_data/python_package/

root@7ccad3d01d39:/local_data/python_package# ls
pyproject.toml  secure_coding_demo_package

root@7ccad3d01d39:/local_data/python_package# python3 -m build
...
Successfully built secure_coding_demo_package-0.0.1.tar.gz and secure_coding_demo_package-0.0.1-py3-none-any.whl


root@7ccad3d01d39:/local_data/python_package# diffoscope dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /local_data/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl

root@7ccad3d01d39:/local_data/python_package# mkdir /local_data/html
root@7ccad3d01d39:/local_data/python_package# diffoscope dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /local_data/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl --html-dir /local_data/html

root@7ccad3d01d39:/local_data/python_package# strip-nondeterminism dist/secure_coding_demo_package-0.0.1-py3-none-any.whl
root@7ccad3d01d39:/local_data/python_package# diffoscope dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /local_data/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl
root@7ccad3d01d39:/local_data/python_package# md5sum dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /local_data/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl

e11a303eef41e70032b4130652e740be  dist/secure_coding_demo_package-0.0.1-py3-none-any.whl
e11a303eef41e70032b4130652e740be  /local_data/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl
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

docker compose logs vault

docker compose exec -ti vault /bin/sh


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
docker compose exec -ti vault /bin/sh
apk add postgresql-client

/ # psql -h postgres -U postgres
Password for user postgres: not_so_secure_default_password
postgres=# create database secure_data;
postgres=# \c secure_data;
secure_data=# create table users (name VARCHAR(255));
secure_data=# \q

```

Configure vault
```shell
/ # vault secrets enable database
Success! Enabled the database secrets engine at: database/

# Configure the connection to postgres

/ # vault write database/config/secure_db \
 plugin_name="postgresql-database-plugin" \
 allowed_roles="secure_coding_role" \
 connection_url="postgresql://{{username}}:{{password}}@postgres:5432/secure_data" \
 username="postgres" \
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

