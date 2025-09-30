#!/bin/bash

# Create DB root directory if not exists
DB_ROOT="./Databases"
mkdir -p "$DB_ROOT"

# Source operations
source ./lib/db_operations.sh
source ./lib/table_operations.sh

# Main menu loop
main_menu() {
    PS3="Enter your choice: "
    COLUMNS=1
    select option in "Create Database" "List Database" "Connect To Database" "Drop Database" "Exit"
    do
        case $REPLY in
            1) create_db ;;
            2) list_dbs ;;
            3) connect_db ;;
            4) drop_db ;;
            5) echo "DBMS Closed"; break ;;
            *) echo "Invalid option, try again." ;;
        esac
    done
}

main_menu