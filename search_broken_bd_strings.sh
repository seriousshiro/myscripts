#!/bin/bash

# db в которой есть закарпченные записи
ekd_ca_db_name=$(docker exec --user user_name ekd-postgresql psql -c "SELECT datname FROM pg_database;" | awk -F '\r' '{print $1}' | grep "ekd_ca")

# кол-во записей в закарапченной таблице
count_strings=$(docker exec --user user_name ekd-postgresql psql --dbname $ekd_ca_db_name -c "
COPY(
SELECT count(*) FROM table_name
) TO STDOUT" | grep [[:digit:]])



# Перебор по тысяче
for ((i = 0; i <= $count_strings; i= $i+1000)); do
    check_between_thousand=$(docker exec --user user_name ekd-postgresql psql --dbname $ekd_ca_db_name -c "
            SELECT * FROM table_name 
            ORDER BY created_date 
            OFFSET $i LIMIT 1000;" 1>/dev/null;
            echo "$?")
            echo "Проверенно - $i"
    # Перебор по сотне
    if [ "$check_between_thousand" != "0" ]; then 
            for ((k = $i; k <= $i+100; k++))
            chech_between_handred=$(docker exec --user user_name ekd-postgresql psql --dbname $ekd_ca_db_name -c "
            SELECT * FROM table_name 
            ORDER BY created_date 
            OFFSET $k LIMIT 1000;" 1>/dev/null;
            echo "$?")
            if [ $chech_between_handred != "0" ]; then
                # Перебор по каждой записи из сотне
                for ((g = $k; g <= $k+100; g++))
                do
                    exit_code_number=$(docker exec --user user_name ekd-postgresql psql --dbname $ekd_ca_db_name -c "
                    SELECT * FROM table_name 
                    ORDER BY created_date 
                    OFFSET $g LIMIT 1;" 1>/dev/null ;
                    echo "$?")
                    echo "Проверенно - $g"
                    if [ "$exit_code_number" != "0" ]; then
                        wrong_string_id=$(docker exec --user user_name ekd-postgresql psql --dbname $ekd_ca_db_name -c "
                        COPY (
                        SELECT id FROM table_name 
                        ORDER BY created_date 
                        OFFSET $g LIMIT 1 ) TO STDOUT;") 
                        echo "'$wrong_string_id'," >> table_wrong_strings_id.txt
                        echo "code is no 0"
                    fi
                done
            done    
            fi
    fi
done