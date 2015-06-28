# docker-lamp with phalcon2

### lamp
* apache2
* mysql
* php5 with library
* php5 phalcon library

### utility
* openssh-server
* git


### docker
```
cd docker-lamp
# build image ( repository name xxxx )
docker build -t xxxx .

# run with bind port
### 81 for apache2
### 2222 for ssh server (no password)
### 33060 for ssh server (password = password ) 
docker run -d -p 81:80 -p 2222:22 -p 33060:3306 -P xxxx
```