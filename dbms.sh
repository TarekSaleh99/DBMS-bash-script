#!/bin/bash

# if database directory not exist create one
DB_ROOT="./Databases"
mkdir -p "$DB_ROOT"

# main menu loop
main_menu() {
    while true; do
        echo "========== Simple DBMS =========="
        echo "1) Create Database"
        echo "2) List Databases"
        echo "3) Connect To Database"
        echo "4) Drop Database"
        echo "5) Exit"
        echo "----------------------------------"
        read -p "Enter choice: " choice

        case $choice in
            1)
                create_db ;;
            2)
                list_dbs ;;
            3)
                connect_to_db ;;
            4)
                drop_db ;;
            5)
                echo "DBMS Closed!"; exit 0 ;;
            *)
                echo "Invalid option, tyr again.";;
        esac
    done
}
# create the db
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
        echo "Connected to database '$dbname'. (Table menu will come later)"
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
main_menu
