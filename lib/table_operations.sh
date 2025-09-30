#!/bin/bash

# Table Menu
table_menu() {
  DB_NAME=$1
  PS3="Enter your choice: "
  COLUMNS=1 # to make the menu vertical 
  select option in "Create Table" "List Tables" "Drop Table" "Insert Row" "Select Rows" "Delete Row" "Update Row" "Disconnect"
  do
    case $REPLY in
      1) create_table "$DB_NAME" ;;
      2) list_tables "$DB_NAME" ;;
      3) drop_table "$DB_NAME" ;;
      4) insert_row "$DB_NAME" ;;
      5) select_rows "$DB_NAME" ;;
      6) delete_row "$DB_NAME" ;;
      7) update_row "$DB_NAME" ;;
      8) echo "Disconnected from $DB_NAME"; break ;;
      *) echo "Invalid option, try again." ;;
    esac
  done
}

create_table() {
  db=$1
  read -p "Enter table name: " tname
  path="$DB_ROOT/$db/$tname"

  # Check if table exists
  if [ -f "$path" ]; then
    echo "Table already exists!"
    return
  fi

  # Validate column count (must be integer > 0)
  while true; do
    read -p "How many columns? " col_count
    if [[ $col_count =~ ^[1-9][0-9]*$ ]]; then
      break
    else
      echo "Please enter a valid positive number."
    fi
  done

  cols=""
  types=""
  pk=""

  for ((i=1; i<=col_count; i++)); do
    echo "---------------------------"
    echo "Column $i of $col_count"

    # Column name validation (not empty)
    while true; do
      read -p "Enter column name: " cname
      if [[ -n "$cname" ]]; then
        break
      else
        echo "Column name cannot be empty."
      fi
    done

    # Datatype validation (must be 'string' or 'int')
    while true; do
      read -p "Enter datatype (string/int): " ctype
      if [[ "$ctype" == "string" || "$ctype" == "int" ]]; then
        break
      else
        echo "Invalid type. Choose 'string' or 'int'."
      fi
    done

    cols+="$cname,"
    types+="$ctype,"

    # Ask for PK only once
    if [[ -z "$pk" ]]; then
      read -p "Is this column a Primary Key? (y/n): " ispk
      if [[ $ispk == "y" ]]; then
        pk=$cname
        echo "Primary Key set to '$cname'."
      fi
    fi
  done

  # Trim trailing commas (remove last comma)
  cols="${cols%,}"
  types="${types%,}"

  # Save structure
  echo "Columns:$cols" > "$path"
  echo "Types:$types" >> "$path"
  echo "PK:$pk" >> "$path"

  echo "Table '$tname' created successfully!"
}


list_tables() {
  db=$1
  echo "Tables in '$db':"
  ls "$DB_ROOT/$db"
}

drop_table() {
  db=$1
  read -p "Enter table name to drop: " tname
  path="$DB_ROOT/$db/$tname"
  if [ -f "$path" ]; then
    rm "$path"
    echo "Table '$tname' deleted."
  else
    echo "Table not found!"
  fi
}
