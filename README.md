# jenkins-slave

Node image for Jenkins CI server

* Ubuntu base image
* OpenJDK 1.8.242
* OpenJDK 13.0.2 (home: /opt/jvm/jdk13.0.2)
* Jenkins remoting client: https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/3.17/remoting-3.17-sources.jar
* Additional apps:
    * google-cloud-sdk
    * git
    * maven
    * rsync
    * unzip
    * yarn
    * sed
    * bash
    * zip
    * xmlstarlet
    * libltdl7
    * bzip2
    * openconnect
    * sudo
    * jq
    * rename
    * libglib2.0-0
    * google-chrome-stable
    * mono-complete
    * python3-pip
    * nodeja
    * npm
    * n
    * box-cli 

#### Requirements
The host system has a user with uid 1000 (jenkins user) and a docker group with gid 999.

### Example docker-compose file:
```yaml
jenkins-slave:
  # Jenkins user is hardwired into jenkins master container. Re-use it here 
  user: "1000"
  restart: always
  image: codefabrik/jenkins-slave:latest
  container_name: jenkins-slave
  environment:
    # Use connection parameters given by jenkins master
    - JNPL_URL=http://[jenkins master FQDN]/computer/slave-1/slave-agent.jnlp
    - SECRET=ffc539f1a8252dc87ddbd96f23464d92c66565d4635c6402ce6e9bc1628ddd91
    - WORKDIR=/home/jenkins
    # Use additional parameters, e.g. no certificate check for self-signed certificates
    - OPTIONS=-noCertificateCheck
  volumes:
    - /docker/volumes/jenkins-slave/:/home/jenkins/
```
