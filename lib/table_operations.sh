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

  # 1) Check if table exists
  if [ ! -f "$path" ]; then
    echo "❌ Table not found!"
    return
  fi

  # 2) Extract schema
  cols=$(sed -n '1s/Columns://p' "$path")   # first line, strip "Columns:"
  types=$(sed -n '2s/Types://p' "$path")    # second line, strip "Types:"
  pk=$(sed -n '3s/PK://p' "$path")          # third line, strip "PK:"

  # Turn comma-separated cols/types into arrays
  IFS=',' read -ra col_arr <<< "$cols"
  IFS=',' read -ra type_arr <<< "$types"

  # 3) Build new row
  new_row=""

  for i in "${!col_arr[@]}"; do
    cname=${col_arr[$i]}
    ctype=${type_arr[$i]}

    # ask for value
    read -p "Enter value for column '$cname' ($ctype): " value

    # datatype check with awk-like regex
    if [[ "$ctype" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
      echo "❌ Invalid input: '$cname' must be an integer."
      return
    fi

    # primary key check → must be unique
    if [[ "$cname" == "$pk" ]]; then
      # search column index with awk
      col_index=$((i+1))
      exists=$(awk -F',' -v idx="$col_index" -v val="$value" 'NR>4 && $idx==val {print "yes"}' "$path")
      if [[ "$exists" == "yes" ]]; then
        echo "❌ Duplicate primary key '$value'."
        return
      fi
    fi

    # append to row
    if [ -z "$new_row" ]; then
      new_row="$value"
    else
      new_row="$new_row,$value"
    fi
  done

  # 4) Append row to file
  echo "$new_row" >> "$path"
  echo "✅ Row inserted successfully!"
}


select_rows() {
  db=$1
  read -p "Enter table name: " tname
  path="$DB_ROOT/$db/$tname"

  # Check if table exists
  if [ ! -f "$path" ]; then
    echo "Table not found!"
    return
  fi

  # Extract metadata
  cols=$(sed -n '1s/^Columns://p' "$path")
  types=$(sed -n '2s/^Types://p' "$path")
  pk=$(sed -n '3s/^PK://p' "$path")

  # Print column headers
  echo "--------------------------------------"
  echo "Table: $tname"
  echo "Columns: $cols"
  echo "Primary Key: $pk"
  echo "--------------------------------------"

  # Use awk to pretty print rows
  awk -F',' '
    NR>3 {
      printf "%-5d", NR-3     # Row number
      for (i=1; i<=NF; i++) {
        printf "| %-15s", $i  # Print each field with padding
      }
      print ""
    }
  ' "$path"

  echo "--------------------------------------"
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
  tail -n +4 "$path" | nl -v1 -w3 -s". "

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
