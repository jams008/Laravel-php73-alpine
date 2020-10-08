# Laravel php 73 alpine
Images Docker For Laravel or other PHP 7.3 alpine 
## Service running

| Container Name | Service Name |
| :------------: | :----------: |
| APP            | PHP73-FPM  |
| -              | Crontab    |
| -              | Supervisor |
| -              | Git Bare |
| Web Server     | Nginx    |
| DB             | Mariadb  |

## Envirement Config 
>Edit envirement this docker-compose.yml file 

Example :
- NAME_REPO: monitoring
- SSH_PORT: 57713
- SSH_PASSWORD: testtest
- MYSQL_DATABASE: wp
- MYSQL_ROOT_PASSWORD: testtest
- SERVICE_TAGS: dev
- SERVICE_NAME: mysql

## Volume / Mount Host Config 
>Edit volume this docker-compose.yml file 

Example :
```
    volumes:
      - ./webroot:/var/www
      - ./php-fpm/conf/local.ini:/usr/local/etc/php/php.ini
```
## Server_name Nginx Config 
>Edit file this ./nginx/conf/app.conf 

Example : 
```
    server_name example.com;
```


### Refrence 
- [link](https://www.digitalocean.com/community/tutorials/how-to-set-up-laravel-nginx-and-mysql-with-docker-compose)
- [link](https://medium.com/swlh/wordpress-deployment-with-nginx-php-fpm-and-mariadb-using-docker-compose-55f59e5c1a)