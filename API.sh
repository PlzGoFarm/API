#!/bin/bash

echo -ne '\nСкрипт для использования админской API Netangels. By GLEBABAS for VASYLIY\n\n'
echo -ne '1 - API запрос на восстановление контейнера Хостинга\n'
echo -ne '2 - API запрос на воостановление структуры сайта контейнера Хостинга\n'
echo -ne '3 - API запрос на поиск сайта по услугам ОХ/ВХ\n'
echo -ne '4 - API запрос для поиска ID пользователя по логину\n'
echo -ne '5 - API запрос для включения почты, нужно знать ID пользователя (Запрос номер 4)\n'
echo -ne '6 - API запрос на изменение параметра почты free_quota, нужно знать ID пользователя (Запрос номер 4)\n'
echo -ne '7 - API запрос для поиска ID почтового домена, нужно знать ID пользователя (Запрос номер 4)\n'
echo -ne '8 - API запрос для передачи почтового домена, нужно знать ID пользователя, которому передаем (Запрос 4) и ID почтового домена (Запрос 7)\n'
echo -ne '9 - API запрос позволяет узнать дату отключения контейнера\n'
echo -ne '10 - API запрос позволяет установить дату отключения контейнера\n\n'
echo -ne 'Пожалуйста, введите цифру от 1 до 10 для выбора необходимого запроса: '

read number

if [[ "$number" -eq 1 ]]; then
	echo -ne '\nВведите ID контейнера без C: '
	read Container_ID

	curl -XPUT https://rest-api-auth.prod.netangels.ru/hosting2/v1/containers/"$Container_ID"/undelete --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .
fi
if [[ "$number" -eq 2 ]]; then
	echo -ne '\nВведите ID сайта в контейнере: '
	read Site_ID

	curl -XPUT https://rest-api-auth.prod.netangels.ru/hosting2/v1/virtualhosts/"$Site_ID"/repair --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .

fi
if [[ "$number" -eq 3 ]]; then
	echo -ne '\nВведите имя сайта: '
	read Site_Name

	curl https://rest-api-auth.prod.netangels.ru/hosting2/v1/virtualhosts/byname/"$Site_Name" --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .
fi
if [[ "$number" -eq 4 ]]; then
	echo -ne '\nВведите логин клиента: '
	read User_ID

	curl https://rest-api-auth.prod.netangels.ru/mail/v1/users/bylogin/"$User_ID" --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq . | grep '"id"'

fi
if [[ "$number" -eq 5 ]]; then
	echo -ne '\nВведите ID клиента: '
	read User_ID

	curl -XPUT -d '{"state": "ENABLED"}' https://rest-api-auth.prod.netangels.ru/mail/v1/users/{"$User_ID"}/setstate --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .
fi
if [[ "$number" -eq 6 ]]; then
	echo -ne '\nВведите ID клиента: '
	read User_ID
	echo -ne '\nВведите нужное значение, например 3000 (3Гб): '
	read Free_Quota

	curl -XPUT -d '{"free_quota": '"$Free_Quota"', "paid_quota": 0, "paid_quota_enabled": false}' https://rest-api-auth.prod.netangels.ru/mail/v1/users/{"$User_ID"} --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .
fi
if [[ "$number" -eq 7 ]]; then
	echo -ne '\nВведите ID пользователя: '
	read User_ID

	curl https://rest-api-auth.prod.netangels.ru/mail/v1/users/{"$User_ID"}/domains?paginator.order=name --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .
fi
if [[ "$number" -eq 8 ]]; then
	echo -ne '\nВведите ID пользователя, которому передаем почтовый домен: '
	read User_ID
	echo -ne '\nВведите ID почтового домена, который хотим передать: '
	read Mail_ID

	curl -XPUT -d '{"user_id": '"$User_ID"'}' https://rest-api-auth.prod.netangels.ru/mail/v1/domains/"$Mail_ID"/setowner --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .
fi
if [[ "$number" -eq 9 ]]; then
	echo -ne '\nВведите имя контейнера (Полное, вместе с C): '
	read container_name

	curl -s https://rest-api-auth.prod.netangels.ru/monitoring/h2/disable_date/"$container_name" --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .

fi
if [[ "$number" -eq 10 ]]; then
	echo -ne '\nВведите имя контейнера (Полное, вместе с C): '
	read container_name
	echo -ne '\nВведите новую дату отключения контейнера в формате год-месяц-дата(xxxx-xx-xx): '
	read off_date
	#echo -ne '\nВведите время отключение контейнера в формате час:минута:секунда: '
	#read off_time

	curl -s -XPOST -d'{"disable_date": "'$off_date'T00:00:00Z"}' https://rest-api-auth.prod.netangels.ru/monitoring/h2/disable_date/"$container_name" --cert ~/.tsh/keys/auth.netangels.ru/"$USER"-x509.pem --key ~/.tsh/keys/auth.netangels.ru/"$USER" | jq .
fi
