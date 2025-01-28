#! /usr/bin/bash

shopt -s extglob

############################## Setting up the Database ######################################

database="/home/nouran/Downloads/Bash/DBMS_PROJECT/database"

if [[ -e $database ]]
then
        cd $database
else
        mkdir $database
        cd $database
fi

echo "Database is Ready"


########################## Database Menu Functionalities ########################################

# To create a table
create_table() 
{
    read -p "Enter table name: " tableName

    if [[ -e "$tableName" ]]
    then
        echo "Table already exists."
    else
        touch "$tableName"
        touch "$tableName.meta"

        echo "Define columns for the table."
        read -p "Enter the number of columns: " columnCount
        while ! [[ $columnCount =~ ^[0-9]+$ ]]
        do
            read -p "Please enter a valid number for column count: " columnCount
        done
        
        pkColumn=""
  
        for (( i=0;i<columnCount;i++ ))
        do
            read -p "Enter name of column $((i+1)) : " columnName
            read -p "Enter data type of column $((i+1)) (e.g. int,str,float,...): " columnType
            if [[ -z "$pkColumn" ]]
            then
                read -p "Do you want to make this column the primary key (yes/no)? " isPK
                 if [[ "$isPK" =~ ^([Yy][Ee][Ss]|[Yy])$ ]]
                then
                    pkColumn="$columnName"
                    echo "$columnName:$columnType:PK" >> "$tableName.meta"
                else
                    echo "$columnName:$columnType" >> "$tableName.meta"
                fi
            else
                echo "$columnName:$columnType" >> "$tableName.meta"
            fi
        done
        
        if [[ -z "$pkColumn" ]]
        then
            echo "No primary key was assigned. Please assign a primary key."
            rm "$tableName" "$tableName.meta" 
            return
        fi
        echo "Table $tableName created successfully with its metadata."
    fi
}


# To list tables
list_tables()
{
    echo "Tables in the database:"
    ls *.meta
}

#insert into table
insert_into_table() 
{
    read -p "Enter the name of the table to insert data into: " tableName

    if [[ ! -e "$tableName" ]]
    then
        echo "Table does not exist."
        return
    fi

    declare -a columns
    declare -a types
    
    while read -r line; 
    do
        columnName=$(echo $line | cut -d':' -f1) 
        columnType=$(echo $line | cut -d':' -f2)
        columns+=("$columnName")
        types+=("$columnType")
    done < "$tableName.meta"

    row=""
    
    for (( i=0; i<${#columns[@]} ; i++ ))
    do
        read -p "Enter value for column ${columns[$i]} (${types[$i]}): " value
        row+="$value:"
    done
    row="${row::-1}"
    echo "$row" >> "$tableName"
    echo "Data inserted successfully into $tableName."
}




########################## Main Menu Functionalities ########################################
#to create a database
create_database() 
{
    read -p "Please Enter Database's Name: " dbName
    if [[ -e $dbName ]]
    then
        echo "Database already exists."
    else
        mkdir $dbName
        echo "Database $dbName is created successfully."
    fi
}

#to list databases
list_databases() 
{
    echo "Databases in the system:"
    ls
}

connect_to_database(){
    PS3=$'\nPlease select a database to connect to: '  
    list_of_dbs=$(ls)  
    if [[ $list_of_dbs == "" ]]
    then
    	echo "No databases in the system!"
    else
    select choice in $list_of_dbs  
    do
        if [ -n "$choice" ]; then 
            cd "$choice"  
            echo "You are now connected to $choice."
            
            database_menu
           
            break
        else
            echo "Invalid choice. Please select a valid database."
        fi
    done
    fi
cd $database
PS3=$'\nPlease select an option: '
}

#to drop database
drop_database(){
    PS3=$'\nPlease select a database to drop : '  
    list_of_dbs=$(ls)  
    if [[ $list_of_dbs == "" ]]
    then
    	echo "No databases in the system!"
    else
    select choice in $list_of_dbs  
    do
        if [ -n "$choice" ]; then 
            rmdir $choice 
            echo "You are dropped table $choice."
            break
        else
            echo "Invalid choice. Please select a valid database."
        fi
    done
    fi
cd $database
PS3=$'\nPlease select an option: '
}


########################## Database Menu ########################################
database_menu() {
    PS3=$'\nPlease select an option: '
    while true
    do
        echo " "
        echo "<------------- DATABASE MENU ------------->"
        select dbChoice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Back to Main Menu"
        do
            case $dbChoice in
                "Create Table")
                    create_table
                    break
                    ;;
                "List Tables")
                    list_tables
                    break
                    ;;
                "Drop Table")

                    break
                    ;;
                 "Insert into Table")
                    insert_into_table
                    break
                    ;;
                 "Select From Table")
                    break
                    ;;
                "Delete From Table")
                    break
                    ;;
                "Back to Main Menu")
                    cd "$database"
                    return
                    ;;
                *)
                    echo "Invalid choice. Please choose from the menu."
                    ;;
            esac
        done
    done
}

########################## Main Menu  ########################################
PS3=$'\nPlease select an option: '

wantsToExit=1
while [[ $wantsToExit -eq 1 ]]
do
        echo " "
	echo -e '<------------------- WELCOME TO THE DATABASE ---------------------> \n'
	select choice in "Create Database" "List Databases" "Connect To Databases" "Drop Database" "Exit"
	do
            clear
	    case $choice in
		"Create Database")
		        create_database 
		        break
		    ;;
		"List Databases")
		        list_databases
		        break
		    ;;
		"Connect To Databases")
		    	connect_to_database
		    	break
		    ;;
		"Drop Database")
		    	drop_database
		    	break
		    ;;
		"Exit") 
		    	wantsToExit=0
		    	echo "Exiting..."
		    	break
		    ;;
		*)
		    echo "Invalid choice. Please choose from 1 to 5."
		    ;;
	    esac
	done
done
