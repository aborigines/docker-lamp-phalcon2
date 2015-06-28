# docker-lamp with phalcon2

### lamp
* apache2
* mysql
* php5 with library
 - phalcon library (manual complie)

### utility
* openssh-server
* git


### docker
```
# clone project
git clone docker-lamp

# go to project directory
cd docker-lamp

# build image ( repository name xxxx )
docker build -t xxxx .

# run with bind port
### 81 for apache2
### 2222 for ssh server (password = password)
### 33060 for mysql server (no password ) 
docker run -d -p 81:80 -p 2222:22 -p 33060:3306 -P xxxx
```