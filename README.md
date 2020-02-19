# jenkins-slave

Node image for Jenkins CI server

* Ubuntu base image
* OpenJDK 1.8.242
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
    * mono-devel
    * kubectl
    * python3-pip 

### Example docker-compose file:
```yaml
jenkins-slave:
  restart: always
  image: jenkins-slave:latest
  container_name: jenkins-slave
  external_links:
    - jenkins
  environment:
    - JNPL_URL=http://jenkins:8080/computer/node/slave-agent.jnlp
    - SECRET=20467030404791871aec4d71207d6ade37456d3f82f4741712308cafbc6506de
  volumes:
    - /docker/volumes/jenkins-slave/:/home/jenkins
```