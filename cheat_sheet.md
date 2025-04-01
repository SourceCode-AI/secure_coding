
Vault
=====

Vault KV
--------

~ 15 mins

```bash
# verify creds
vault status
# vault operator unseal
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



Reproducible builds exercise
============================

Reproducing a package ~ 20min

```shell
root@debian12:/secure_coding# cd /secure_coding/local_data/
root@debian12:/secure_coding/local_data# tree
.
├── hello_world.c
├── malwaretest.c
├── prebuild_package
│   └── secure_coding_demo_package-0.0.1-py3-none-any.whl
└── python_package
    ├── pyproject.toml
    └── secure_coding_demo_package
        ├── __init__.py
        └── sneaky_package
            └── __init__.py

5 directories, 6 files


root@debian12:/secure_coding/local_data# cd python_package/
root@debian12:/secure_coding/local_data/python_package# python3 -m build
...
Successfully built secure_coding_demo_package-0.0.1.tar.gz and secure_coding_demo_package-0.0.1-py3-none-any.whl


root@debian12:/secure_coding/local_data/python_package# strip-nondeterminism dist/secure_coding_demo_package-0.0.1-py3-none-any.whl
root@debian12:/secure_coding/local_data/python_package# strip-nondeterminism dist/secure_coding_demo_package-0.0.1-py3-none-any.whl
root@debian12:/secure_coding/local_data/python_package# diffoscope dist/secure_coding_demo_package-0.0.1-py3-none-any.whl ../prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl
root@debian12:/secure_coding/local_data/python_package# md5sum dist/secure_coding_demo_package-0.0.1-py3-none-any.whl ../prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl
81cab8eab03f8255a8c05bb014c40824  dist/secure_coding_demo_package-0.0.1-py3-none-any.whl
81cab8eab03f8255a8c05bb014c40824  ../prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl

root@7ccad3d01d39:/secure_coding/python_package# mkdir /secure_coding/html
root@7ccad3d01d39:/secure_coding/python_package# diffoscope dist/secure_coding_demo_package-0.0.1-py3-none-any.whl /secure_coding/prebuild_package/secure_coding_demo_package-0.0.1-py3-none-any.whl --html-dir /local_data/html


```


compare compiled code ~5 min
```shell
root@debian12:/secure_coding/local_data# cd /secure_coding/local_data/
root@debian12:/secure_coding/local_data# ls
hello_world.c  malwaretest.c  prebuild_package	python_package
root@debian12:/secure_coding/local_data# cat hello_world.c
root@debian12:/secure_coding/local_data# cat malwaretest.c

root@debian12:/secure_coding/local_data# gcc hello_world.c -o a.out
root@debian12:/secure_coding/local_data# gcc malwaretest.c -o b.out
root@debian12:/secure_coding/local_data# ls
a.out  b.out  hello_world.c  malwaretest.c  prebuild_package  python_package
root@debian12:/secure_coding/local_data# diffoscope a.out b.out

```

CTX Malware exercise ~ 15 min
---


```shell
root@debian12:/secure_coding/local_data# mkdir /var/www/html/diffoscope
root@debian12:/secure_coding/local_data# diffoscope a.out wannabe_ransomware --html-dir /var/www/html/diffoscope

root@debian12:/secure_coding# cd /secure_coding/malware/
root@debian12:/secure_coding/malware# ls
b40297af54e3f99b02e105f013265fd8d0a1b1e1f7f0b05bcb5dbdc9125b3bb5.gz  ctx-0.1.2.tar.gz
root@debian12:/secure_coding/malware# diffoscope ctx-0.1.2.tar.gz b40297af54e3f99b02e105f013265fd8d0a1b1e1f7f0b05bcb5dbdc9125b3bb5.gz
```
