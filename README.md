# sql-learning-workshop

A workshop that gives an overview of SQL on PostgreSQL 12 as well as an overview of some database features.

## Requires

* docker
* docker-compose

## Setup

1. Clone repository
2. Navigate to repo directory
3. Execute `./wsinit`
4. Execute `./ctbash`
5. Execute `pipenv install`
6. Execute `pipenv shell`
7. Open a new terminal and navigate to the repo dir.
8. Execute `./ctpsql`

Exercises are available in the workshop subdirectory

## Teardown

### ctpsql

1. Enter `\q` or press `Ctrl+D`

### ctbash

1. Enter `exit` or press `Ctrl+D` (do this twice, once to exit pipenv shell, the next to exit the container)

Finally execute `./wskill`

## Contents

This workshop will provide a PostgreSQL 12 database via docker. It will build a pgAdmin and a Grafana image with pre-set configrations and launch the containers.
