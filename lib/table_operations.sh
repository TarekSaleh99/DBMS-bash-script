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

#insert_row

insert_row() {
  db=$1
  read -p "Enter table name: " tname
  path="$DB_ROOT/$db/$tname"

  # Check if table exists
  if [ ! -f "$path" ]; then
    echo "❌ Table not found!"
    return
  fi

  # --- Read table structure ---
  cols=$(grep "^Columns:" "$path" | cut -d':' -f2)
  types=$(grep "^Types:" "$path" | cut -d':' -f2)
  pk=$(grep "^PK:" "$path" | cut -d':' -f2)

  # Convert into arrays
  IFS=',' read -ra col_arr <<< "$cols"
  IFS=',' read -ra type_arr <<< "$types"

  row=""

  # Loop through each column
  for i in "${!col_arr[@]}"; do
    cname=${col_arr[$i]}   # column name
    ctype=${type_arr[$i]} # column type

    while true; do
      read -p "Enter value for $cname ($ctype): " value

      # --- datatype check ---
      if [[ $ctype == "int" && ! $value =~ ^[0-9]+$ ]]; then
        echo "❌ $cname must be an integer."
        continue
      fi

      # --- primary key check ---
      if [[ $cname == "$pk" ]]; then
        if awk -F',' -v col=$((i+1)) -v val="$value" 'NR>3 {if ($col == val) {exit 1}}' "$path"; then
          : # ok, no duplicate found
        else
          echo "❌ Duplicate primary key '$value'."
          continue
        fi
      fi

      break
    done

    # Add to row string
    if [ -z "$row" ]; then
      row="$value"
    else
      row="$row,$value"
    fi
  done

  # Append the new row to the file
  echo "$row" >> "$path"
  echo "✅ Row inserted successfully!"
}


select_rows() {
  db=$1
  read -p "Enter table name: " tname
  path="$DB_ROOT/$db/$tname"

  # Check if table exists
  if [ ! -f "$path" ]; then
    echo "❌ Table not found!"
    return
  fi

  # Read structure
  cols=$(grep "^Columns:" "$path" | cut -d':' -f2)

  IFS=',' read -ra col_arr <<< "$cols"

  echo "-----------------------------------------"
  echo "📋 Data in table '$tname'"
  echo "-----------------------------------------"

  # Print header row (columns)
  for cname in "${col_arr[@]}"; do
    printf "%-15s" "$cname"
  done
  echo
  echo "-----------------------------------------"

  # Print each data row (skip first 3 lines)
  tail -n +4 "$path" | while IFS=',' read -ra fields; do
    for field in "${fields[@]}"; do
      printf "%-15s" "$field"
    done
    echo
  done

  echo "-----------------------------------------"
}

delete_row() {
  db=$1
  read -p "Enter table name: " tname
  path="$DB_ROOT/$db/$tname"

  # Check if table exists
  if [ ! -f "$path" ]; then
    echo "Table '$tname' does not exist!"
    return
  fi

  # Count total lines and compute number of data rows (lines after the 3 header lines)
  total_lines=$(wc -l < "$path" | tr -d ' ')
  if [ "$total_lines" -le 3 ]; then
    echo "Table '$tname' has no data rows to delete."
    return
  fi
  data_lines=$((total_lines - 3))

  # Show only data rows, numbered from 1 (we skip header lines 1-3)
  echo "Current data rows in table '$tname':"
  tail -n +5 "$path" | nl -v1 -w3 -s". "

  # Ask which data-row number to delete (1..data_lines)
  read -p "Enter data row number to delete (1-$data_lines): " rownum

  # Validate input: must be integer within [1..data_lines]
  if ! [[ "$rownum" =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid input: please enter a positive integer."
    return
  fi
  if [ "$rownum" -lt 1 ] || [ "$rownum" -gt "$data_lines" ]; then
    echo "Row number out of range. Valid range is 1 to $data_lines."
    return
  fi

  # Compute the actual file line to remove (headers are 3 lines)
  file_line=$((rownum + 3))

  # Use a temporary file and awk to write everything except the target line,
  # then replace the original file atomically.
  tmp=$(mktemp) || { echo "Failed to create temporary file"; return; }

  if awk -v skip="$file_line" 'NR != skip { print }' "$path" > "$tmp"; then
    mv "$tmp" "$path"
    echo "Row $rownum (file line $file_line) deleted successfully from '$tname'."
  else
    rm -f "$tmp"
    echo "Failed to delete row. No changes made."
  fi
}
