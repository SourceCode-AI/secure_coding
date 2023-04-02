Secure Coding Lab exercise
==========================

**IMPORTANT: always check for the latest version prior to the lab/seminar. Changes may occur**

NOTICE: this repository also contains malware samples, it is possible your AV software may show alerts


Instructions & prerequisites:
-----------------------------

- [docker compose](https://docs.docker.com/compose/)
- copy of this repository
- all the commands should be run in the same directory hwere you cloned the repository. docker compose will pick up the configuration file automatically
- run `docker compose pull` to pull the dependencies
- run `docker compose build` to build the custom container with preinstalled tools

  - if there are updates, you need to re-run this step, run `docker compose down` first to remove any previous work

- run `docker compose up -d` to start the containers. You should see containers `postgres` and `vault` as running in logs.

  - Check that there is no error in those two containers!
  - run `docker compose down` to shutdown the running containers

    - shutting down all containers will also remove all data, all work/modifications you have done will be reset
    - you can use this to reset your environment if you misconfigure something

- you are now ready for the exercise!


Manual installation
-------------------

If there is a problem with the docker compose containers or you wish to not use the docker then the following software is required:

- password protected PostgreSQL instance + postgres client
- [Hashicorp Vault](https://www.vaultproject.io)
- python3 with venv, build and pip modules installed
- [diffoscope & strip-nondeterminism tools](https://reproducible-builds.org/tools/)
- gcc

You can also refer to the included docker configuration files which basically contains installation instructions of all dependencies into ubuntu

