# docker-lamp

### lamp
* apache2
* mysql
* php5 with library

### utility
* openssh-server
* git


### docker
```
# build image ( repository name xxxx )
docker build -t xxxx .

# run with bind port
### 81 for apache2
### 2222 for ssh server (no password)
### 33060 for ssh server (password = password ) 
docker run -d -p 81:80 2222:22 33060:3306 -P xxxx
```