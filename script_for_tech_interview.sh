#!/bin/bash

#Скачивание файла list.out
wget https://raw.githubusercontent.com/GreatMedivack/files/master/list.out 

#определение переменной name
#Если скрипт запускается ./script , то проставляется имя сервера "server"
if ["$1" -qe ""]
	then name=server_$(date +"%d_%m_%Y")
else  name=$1_$(date +"%d_%m_%Y")
fi

#фильтрация по статусу и перенос первого столбца list.out с результата grep'a
grep 'Running' ./list.out | awk '{print$1}' > "$name"_running.out && rm list.out

#Если папки achives нет, то это эта команда ее создает.
mkdir archives

#архивирование
tar -czpf ./archives/"$name".tar.gz "$name"_running.out && rm  ./"$name"_running.out

#проверка на целостность архива.
#За lifecheck взял открытие содержимого архива
if tar -tvzf $(find ./archives/ -name "$name*tar.gz") > /dev/null
	then echo "Everything is great"
else echo "Something wrong with yours archive. Please check this out."
fi
