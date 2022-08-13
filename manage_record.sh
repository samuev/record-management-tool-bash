#! /bin/bash

#===============================================================================================
# NAME:
# PURPOSE: THIS IS RECORD MANAGEMENT TOOL!
# DESCRIPTION: 
# This script provide records management abilities like:
# Insert Record, Delete Record, Update Record Name, Update Record Amount, Search Record by name, 
# Print Total Record Amount, Print All Record list
# USAGE:
# Run as regular bash script: ./script_name.sh
# Or Run with new record_file_list as positional arguments:  ./script_name.sh record_file_list
# The log file including all user actions and events will be created automatically 
# AUTHOR: Stas Amuev
# REVIEWER:
# VERSION: 0.1 
# LINK_TO_GIT:
#=================================================================================================

default_record_file_name="record_list"


############################-Functions-########################################
# Function Purpose: search record lines from record list and return counted line number
f_search_record_lines () {
local __search_lines=$1
local search_lines
echo "record_name for search is: $record_name"
search_lines=$(cat $record_file | grep $record_name | wc -l)
echo "search lines result is: $search_lines"
eval $__search_lines="'$search_lines'"
}
#------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: check record name if typed valid expected value and return True or False
f_check_record_name() {
local __check_record_name=$1
local set_check_result
if [[ "$record_name" ]] && [[ "${record_name}" =~ ^[a-zA-Z]+$ ]]; then  # check if input record name are not empty and not numeric by regex
   set_check_result="True"                                              # Valid record name
else
   set_check_result="False"                                             # Invalid record name 
fi
eval $__check_record_name="'$set_check_result'"                         # return the value True\False by eval
}
#------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: check record amount if typed valid expected value and return True or False
f_check_record_amount() {
local __check_record_amount=$1
local set_check_result
# check if input record amount value are not empty and not alphabetic by regex and greater than zero
if [[ "$record_amount" ]] && [[ "${record_amount}" =~ ^[[:digit:]]+$ ]] && [[ "$record_amount" -gt 0 ]]; then  
   set_check_result="True"                                              # Valid record amount
else
   set_check_result="False"                                             # Invalid record amount 
fi
eval $__check_record_amount="'$set_check_result'"                       # return the value True\False by eval
}

#------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: print all record list with amounts from record file
f_print_all () {
clear
echo "Print all record lists:"
if ! [ -s $record_file ]; then
   echo "The record file is empty - try insert new record! "
else
   cat $record_file | sort -k1                                              # print all record file sorted by firts column(record name)
   f_write_to_log "Print all record list with amounts" "done" "Succeeded"   # add event to LOG file
fi   
}

#------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: Write all success or fail events to the log file
f_write_to_log () {
local event_name=$1
local event_message=$2
local event_status=$3

echo "$(date +'%D %T') | Event: $event_name | Message: $event_message | Status: $event_status" >> $log_file 

}
#------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: Insert new record to records file
f_insert_new_record () {

local record_name=$1
local res_check_amount=$2
local record_amount=$3

if [ "$res_check_amount" == "True" ]; then  
          echo "$record_name,$record_amount" >> $record_file
          echo -e "\e[1;32m Insert New Record - Sucessfully! \e[0m"   
          f_write_to_log "Inser New Record" "done" "Successfully"                                              # add event to LOG file   
else
          echo -e "\e[1;31m Invalid input of record amount must include only digits - try again! \e[0m"  
          f_write_to_log "Inser Record" "Invalid input the record amount must include only digits" "Failed"    # add event to LOG file
fi
}
#------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: Replace record amount with new updated value to existed recod
f_replace_record_amount () {

local selected_record=$1
local res_check_amount
local updated_amount=0
local cut_record_name=$(echo $selected_record | cut -d "," -f1)                      # cut the record name from output
local cut_amount=$(echo $selected_record | cut -d "," -f2)                           # cut the record amount from output

read -p "Enter record amount in digits: " record_amount
echo "$record_amount"
f_check_record_amount res_check_amount                             # call check record amount function returned True\False if amount valid\invalid   
if [ "$res_check_amount" == "True" ]; then   
     updated_amount=$(($cut_amount+$record_amount)) 
     echo "updated amount is: $updated_amount"  
     sed -i "/^$cut_record_name,/s/[[:digit:]]*$/$updated_amount/" $record_file  # replace record amount with new updated value
     echo -e "\e[1;32m Insert New Record - Successfully! \e[0m"  
     f_write_to_log "Inser New Record" "done" "Successfully"                     # add event to LOG file   
else
     echo -e "\e[1;31m Invalid input of record amount must include only digits - try again! \e[0m" 
     f_write_to_log "Inser Record" "Invalid input the record number must include only digits" "Failed"      # add event to LOG file
fi 
}
#------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: Insert new record to record list if record existed update record amount for this existed record
f_insert_record () {
clear
echo "Insert record"
f_print_all           # call print_all function in order to print all existed records before insert action
local record_name 
local record_amount 
local record_number 
local iterator=1 
local match_result line_number
local res_search_record_lines
local res_check_name
local res_check_amount

read -p "Enter record name: " record_name
echo "$record_name"

f_check_record_name res_check_name                               # call check record name function returned True\False if name valid\invalid   
if [ "$res_check_name" == "True" ]; then  
   f_search_record_lines res_search_record_lines                 # call search record lines function
   if [ "$res_search_record_lines" -eq 0 ]; then                 # if record new and not existed in record list
      read -p "Enter record amount in digits: " record_amount
      echo "$record_amount"
      f_check_record_amount res_check_amount                     # call check record amount function returned True\False if amount valid\invalid   
      if [ "$res_check_amount" == "True" ]; then  
          echo "$record_name,$record_amount" >> $record_file
          echo -e "\e[1;32m Insert New Record - Sucessfully! \e[0m"   
          f_write_to_log "Inser New Record" "done" "Successfully"            # add event to LOG file   
       else
          echo -e "\e[1;31m Invalid input of record amount must include only digits - try again! \e[0m"  
          f_write_to_log "Inser Record" "Invalid input the record amount must include only digits" "Failed"      # add event to LOG file
       fi
    else
       local temp_file="$path/tmp_record_file"
       cat $record_file | grep $record_name > $temp_file
       
       echo "Found record name matches: " 
        while read -r line
         do 
	     echo "$iterator) $line"
	     iterator=$(($iterator + 1))	     
        done < "$temp_file" 
        echo "$iterator) Add as New Record"       
        read -p "Type line number: " record_number           
        if [[ "${record_number}" =~ ^[1-9]+$ ]]; then      # check if input selected record number are not alphabetic by regex
            if [[ $record_number -eq $iterator ]]; then    # if selected option add as new record
               match_result=$(grep -w $record_name $record_file | wc -l) 
               if [[ $match_result -eq 0 ]]; then
                  read -p "Enter record amount in digits: " record_amount
                    echo "$record_amount"
                    f_check_record_amount res_check_amount                            # call check record amount function returned True\False if amount valid\invalid   
                    f_insert_new_record record_name res_check_amount record_amount    # call function insert new record
               else
                   grep -w $record_name $record_file
                   echo "This record already existed!" 
                   echo  -e "\e[1;31m Insert New Record - FAILED! \e[0m"    
                   f_write_to_log "Insert New Record" "Record already exist" "Failed"       # add event to LOG file   
               fi     
            else   
               line_number="$record_number"p
               local selected_record=$(cat $temp_file | sed -n $line_number)
               echo "selected record is: $selected_record"
               f_replace_record_amount $selected_record                                     # call function replace record amount with new updated value
            fi
        else
            echo -e "\e[1;31m Invalid input of record number must include only digits - try again! \e[0m"  
            f_write_to_log "Inser Record" "Invalid input the record number must include only digits" "Failed"      # add event to LOG file
        fi                
    fi         
else
   echo -e "\e[1;31m Invalid input the record name must include only letters - try again! \e[0m"  
   f_write_to_log "Inser Record" "Invalid input the record name must include only letters" "Failed"      # add event to LOG file
fi   
}
#--------------------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: Delete record from record file
f_delete_record () {
clear
f_print_all     
local iterator=1                                             # call print_all function in order to print all existed records
local record_name
local res_search_record_lines
local res_check_name

echo "Select record to delete " 
read -p "Enter record name: " record_name
echo "$record_name"

f_check_record_name res_check_name                           # call check record name function returned True\False if name valid\invalid   
if [ "$res_check_name" == "True" ]; then 
   f_search_record_lines res_search_record_lines             # call search record function

   if [ "$res_search_record_lines" -eq 0 ]; then             # if record not existed in record list
        echo "Record name Not found - try again!"
        echo -e "\e[1;31m Delete Record - Failed! \e[0m"      
        f_write_to_log "Delete Record" "Failed"              # add event to LOG file   
   
   elif [ "$res_search_record_lines" -gt 1 ]; then 
        local temp_file="$path/tmp_record_file"
        cat $record_file | grep $record_name > $temp_file     
        echo "Found record name matches: " 
        while read -r line
         do 
	     echo "$iterator) $line"
	     iterator=$(($iterator + 1))	     
        done < "$temp_file" 
        
        read -p "Type line number: " record_number
           if [[ "${record_number}" =~ ^[1-9]+$ ]]; then      # check if input selected record number are not alphabetic by regex 
              line_number="$record_number"p
              local selected_record=$(cat $temp_file | sed -n $line_number)
              echo selected record is: $selected_record
              grep -vw $selected_record $record_file > temp_record_file  # show all record list except the record name typed for delete then write all to temp_file 
              cat temp_record_file > $record_file                        # replace the original record list file with temp_file data
              rm temp_record_file                                        # remove temp_file
              echo -e "\e[1;32m Record Successfully Deleted! \e[0m"   
              f_write_to_log "Delete Record" "done" "Successfully"              # add event to LOG file   
           else
              echo -e "\e[1;31m Invalid input of record number must include only digits - try again! \e[0m"  
              f_write_to_log "Delete Record" "Invalid input the record number must include only digits" "Failed"      # add event to LOG file
           fi  
   else
       local cut_record_name=$(grep $record_name $record_file | cut -d "," -f1)
       echo "Matched record name for delete is: $cut_record_name" 
       grep -vw $cut_record_name $record_file > temp_record_file  # show all record list except the record name typed for delete then write all to temp_file 
       cat temp_record_file > $record_file                        # replace the original record list file with temp_file data
       rm temp_record_file                                        # remove temp_file
       echo -e "\e[1;32m Record Successfully Deleted! \e[0m"   
       f_write_to_log "Delete Record" "done" "Successfully"          # add event to LOG file   
   fi
else
   echo -e "\e[1;31m Invalid input the record name must include only letters - try again! \e[0m"   
   f_write_to_log "Delete Record" "Invalid input the record name must include only letters" "Failed"      # add event to LOG file
fi   
}
#------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: Update record name
f_update_record_name () {
clear
echo "Update record name"
local new_record_name 
local record_name 
local record_amount 
local record_number 
local iterator=1 
local res_check_name

f_print_all           # call print_all function in order to print all existed records
read -p "Enter record name: " record_name
echo "$record_name"
f_check_record_name res_check_name                         # call check record name function returned True\False if name valid\invalid   
if [ "$res_check_name" == "True" ]; then 
      f_search_record_lines res_search_record_lines        # call search record function
      
      if [ "$res_search_record_lines" -ne 0 ]; then        # if record existed in record list
         local temp_file="$path/tmp_record_file"
         cat $record_file | grep $record_name > $temp_file
       
         echo "Found record name matches: " 
         while read -r line
         do 
	     echo "$iterator) $line"	     
             iterator=$(($iterator + 1))         
         done < "$temp_file" 
         
         read -p "Type line number: " record_number
         if [[ "${record_number}" =~ ^[1-9]+$ ]]; then  # check if input selected record number are not alphabetic by regex
             line_number="$record_number"p
             local selected_record=$(cat $temp_file | sed -n $line_number)
             echo selected record is: $selected_record
             local cut_record_name=$(echo $selected_record | cut -d "," -f1)  # cut record current name from output
             local cut_amount=$(echo $selected_record | cut -d "," -f2)       # cut record amount from output
             read -p "Enter new record name: " new_record_name
             echo "$new_record_name"
             f_check_record_name res_check_name                               # call check record name function returned True\False if name valid\invalid   
             if [ "$res_check_name" == "True" ]; then   
                match_result=$(grep -w $new_record_name $record_file | wc -l)        #check if new record name are uniq
                if [[ $match_result -eq 0 ]]; then
                     sed -i "s/^$cut_record_name,/$new_record_name,/" $record_file   # replace old record name with new record name value
                     echo -e "\e[1;32mReplace New Record Name - Sucessfully! \e[0m"                   
                     f_write_to_log "Update Record Name" "done" "Successfully"                   # add event to LOG file   
                else
                     echo -e "\e[1;31m Invalid input new record name already exist it must be uniq - try again! \e[0m"  
                     f_write_to_log "Update Record Name" "Invalid input record name already exist must be uniq" "Failed"      # add event to LOG file
                fi
             else
                 echo -e "\e[1;31m Invalid input the record name must include only letters - try again! \e[0m"  
                 f_write_to_log "Update Record Name" "Invalid input the record name must include only letters" "Failed"      # add event to LOG file
             fi
         else
             echo -e "\e[1;31m Invalid input of record number must include only digits - try again! \e[0m"  
             f_write_to_log "Update Record Name" "Invalid input the record amount must include only digits" "Failed"      # add event to LOG file
         fi   
      else
          echo -e "\e[1;31m The record not found - try again! \e[0m"   
          f_write_to_log "Update Record Name" "Record not found" "Failed"                                              # add event to LOG file
      fi
else
    echo -e "\e[1;31m Invalid input the record name must include only letters - try again! \e[0m"      
    f_write_to_log "Update Record Name" "Invalid input the record name must include only letters" "Failed"      # add event to LOG file
fi     
}
#----------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: Update record amount for existed record
f_update_record_amount () {
clear

local record_name record_amount record_number iterator=1 
local match_result line_number updated_amount
local res_search_record_lines
local res_check_name
local res_check_amount

f_print_all                                                   # call print_all function in order to print all existed records
read -p "Enter record name: " record_name
echo "$record_name"

f_check_record_name res_check_name                            # call check record name function returned True\False if name valid\invalid   
if [ "$res_check_name" == "True" ]; then 
      f_search_record_lines res_search_record_lines           # call search record function

      if [ "$res_search_record_lines" -ne 0 ]; then           # if record existed in record list
         local temp_file="$path/tmp_record_file"
         cat $record_file | grep $record_name > $temp_file
       
         echo "Found record name matches: " 
         while read -r line
         do 
	     echo "$iterator) $line"	     
             iterator=$(($iterator + 1))         
         done < "$temp_file" 
         
         read -p "Type line number: " record_number
         if [[ "${record_number}" =~ ^[1-9]+$ ]]; then  # check if input selected record number are not alphabetic by regex
             line_number="$record_number"p
             local selected_record=$(cat $temp_file | sed -n $line_number)
             echo selected record is: $selected_record
             local cut_record_name=$(echo $selected_record | cut -d "," -f1)  # cut record_name from output
             local cut_amount=$(echo $selected_record | cut -d "," -f2)       # cut record current amount from output
             read -p "Enter new record amount in digits: " record_amount
               echo "$record_amount"
               f_check_record_amount res_check_amount         # call check record amount function returned True\False if amount valid\invalid   
               if [ "$res_check_amount" == "True" ]; then  
                   sed -i "/^$cut_record_name,/s/[[:digit:]]*$/$record_amount/" $record_file  # replace record amount with new updated value
                   echo -e "\e[1;32m New Record Amount Updated - Sucessfully! \e[0m"          
                   f_write_to_log "Update Record Amount" "done" "Successfully"                # add event to LOG file   
                   rm $temp_file
               else
                  echo -e "\e[1;31m Invalid input of record amount must include only positive digits - try again! \e[0m"  
                  f_write_to_log "Update Record Amount" "Invalid input the record amount must include only positive digits" "Failed"      # add event to LOG file
               fi
         else
            rm $temp_file
            echo -e "\e[1;31m Invalid input of record number must include only digits - try again! \e[0m"          
            f_write_to_log "Update Record Amount" "Invalid input the record number must include only digits" "Failed"      # add event to LOG file
         fi 
    else
       echo -e "\e[1;31m Invalid input the record name NOT existed in record list - try again! \e[0m"  
       f_write_to_log "Update Record Amount" "Invalid input the record name not exist" "Failed"      # add event to LOG file
    fi
else
   echo -e "\e[1;31m Invalid input the record name must include only letters - try again! \e[0m"                 
   f_write_to_log "Update Record Amount - Invalid input the record name must include only letters" "Failed"      # add event to LOG file
fi                
} 
#-----------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: search record by name from record file
f_search_record () {
clear
local record_name
local res_search_record_lines
local res_check_name

f_print_all           # call print_all function in order to print all existed records
read -p "Enter record name for search: " record_name
echo "$record_name"
f_check_record_name res_check_name                                  # call check record name function returned True\False if name valid\invalid 
if [ "$res_check_name" == "True" ]; then 
      f_search_record_lines res_search_record_lines                 # call search record function
      if [ "$res_search_record_lines" -eq 0 ]; then                 # if record not existed in record list
          echo -e "\e[1;31m Record name Not found - try again! \e[0m"                            
          f_write_to_log "Search Record" "Record name Not found" "Failed"     # add event to LOG file
      else
          echo "Search result of record are:"
          grep $record_name $record_file | sort
          echo -e "\e[1;32m Search Record - Success! \e[0m"        
          f_write_to_log "Search Record" "done" "Success"                     # add event to LOG file
      fi
  else
     echo -e "\e[1;31m Invalid input the record name must include only letters - try again! \e[0m"   
     f_write_to_log "Search Record" "Invalid input the record name must include only letters" "Failed"      # add event to LOG file
fi      
}
#-----------------------------------------------------------------------------------------------------------------------------------------------
# Function Purpose: Printing sum of total counting amounts from record file
f_print_total_record_amount (){
clear 
local total_amount=0  
local cut_amount

 echo "Print Total Record Amount"
 if [ -s $record_file ]; then  # check if record file empty!
    while read -r line
     do 
       echo "$line"	   
       cut_amount=$(echo $line | cut -d "," -f2)       # cut record current amount from output  
       let total_amount=$(($total_amount + $cut_amount))          
    done < "$record_file"
 fi    
     if [ $total_amount -ne 0 ];then 
        echo "Total Record Amount is: $total_amount"
        echo -e "\e[1;32m Counting all Record Amounts - Sucessfully! \e[0m"   
        f_write_to_log "Print Total Record Amounts" "done" "Succeeded"                    # add event to LOG file
     else
        echo "No Record Amount: $total_amount"
        echo -e "\e[1;31m Not found Record Amounts - Failed! \e[0m"   
        f_write_to_log "Print Total Record Amounts" "Not found Record Amounts" "Failed"   # add event to LOG file
     fi   
}

#------------------------------------------------------------------------------------------------------------------------------
###############-MAIN START HERE -##################

clear         # clear the screen
input="a"     # initial input variable in order to enter menu while block
path=$(pwd)   # print current path

# Check if user type positional argument with scrip_name
if [ $# -eq 0 ]; then
   record_file="$path/$default_record_file_name"  # Work with default record file
   log_file=$record_file"_log"
   > $log_file                 # create log file
   f_write_to_log "Create log file" "created log file" "Succeeded"     # add event to LOG file

else
# was given positional argument 
   record_file="$path/$1"
   touch $record_file                # create new record file with positional argument name
   log_file=$record_file"_log"
   > $log_file                       # create log file
   f_write_to_log "Create log file" "created log file from positional argument" "Succeeded"     # add event to LOG file

fi

#************ PRINT MENU *************************
while [ "$input" != q ]; do
  echo
  echo -e "\e[1;42m THIS IS RECORD MANAGEMENT TOOL! \e[0m" # mark text line green background colour
  echo -e "\e[1;42m ----------  M E N U ----------- \e[0m"
  echo "Press-[1]  Insert Record "
  echo "Press-[2]  Delete Record"
  echo "Press-[3]  Search Record"
  echo "Press-[4]  Update Record Name"
  echo "Press-[5]  Update Record Amount"
  echo "Press-[6]  Print Total Record Amount"
  echo "Press-[7]  Print All Record Collections"
  echo "Press-[q]  Exit! "                

echo -e "\e[1;44mEnter your choice: \e[0m"                 # mark text line blue background colour
read input

 case "$input" in
   
   1 ) f_insert_record ;;
   
   2 ) f_delete_record ;;

   3 ) f_search_record ;;

   4 ) f_update_record_name ;;

   5 ) f_update_record_amount ;;

   6 ) f_print_total_record_amount ;;

   7 ) f_print_all ;;
   
   q ) echo -e "\e[1;31m You choose Exit - Bye \e[0m"                             # print text red colour
       f_write_to_log "In MENU" "Pressed Exit from program" "Succeeded" ;;        # add event to LOG file

   * ) echo -e "\e[1;31m Invalid choice try again! \e[0m"                          # print text red colour
       f_write_to_log "In MENU" "Pressed Invalid choice try again" "Succeeded" ;;  # add event to LOG file
 esac
done
