#exec gunicorn --env DJANGO_SETTINGS_MODULE=app.my_settings RetailCom.wsgi
gunicorn RetailCom.wsgi:application --bind 0.0.0.0:8000
