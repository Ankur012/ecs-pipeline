#!/usr/bin/expect
set prompt ":|#|\\\$"
eval spawn /usr/bin/python3 /opt/django-helloworld/manage.py createsuperuser --username admin --email admin@mail.com
expect "Password:"   
send "password123@#\r";
expect "Password (again):"  
send "password123@#\r";
interact
