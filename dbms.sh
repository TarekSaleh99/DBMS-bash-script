#!/bin/bash

# if database directory not exist create one 
MK_DIR="./database"
mkdir -p "$MK_DIR"

# main menu loop
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
            create_database ;;
        2)
            list_database ;;
        3)
            connect_to_database ;;
        4)
            Drop_database ;;
        5)
            echo "DBMS Closed!"; exit 0 ;;
        *)
            echo "Invalid option, tyr again.";;
    esac
done