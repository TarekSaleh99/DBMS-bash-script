#!/bin/bash

create_db() {
    echo -n "Enter database name: "
    read -r dbname
    if [ -d "$DB_ROOT/$dbname" ]; then
        echo "Database '$dbname' already exists."
    else
        mkdir "$DB_ROOT/$dbname"
        echo "Database '$dbname' created."
    fi
}

list_dbs() {
    echo "Databases:"
    ls "$DB_ROOT"
}

connect_db() {
    echo -n "Enter database name to connect: "
    read -r dbname
    if [ -d "$DB_ROOT/$dbname" ]; then
        echo "Connected to database '$dbname'."
        table_menu "$dbname"
    else
        echo "Database '$dbname' does not exist."
    fi
}

drop_db() {
    echo -n "Enter database name to drop: "
    read -r dbname
    if [ -d "$DB_ROOT/$dbname" ]; then
        rm -r "$DB_ROOT/$dbname"
        echo "Database '$dbname' dropped."
    else
        echo "Database '$dbname' not found."
    fi
}
