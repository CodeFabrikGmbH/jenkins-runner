FROM ubuntu:16.04

ARG JENKINS_SLAVE_VERSION=3.17
ENV HOME /home/jenkins

# enable apt/https (for adding google cloud repo)
RUN apt-get update && apt-get install -y apt-transport-https wget curl && rm -rf  /var/lib/apt/lists/*

# add google cloud repo
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://packages.cloud.google.com/apt cloud-sdk-jessie main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# add yarn repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# prepare installation of chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list

# prepare mono installation
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | tee /etc/apt/sources.list.d/mono-official-stable.list

# add kubernetes repo
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list

RUN apt-get update \
    && apt-get install -y --allow-unauthenticated \
    build-essential gcc python-dev python-setuptools google-cloud-sdk \
    git \
    maven \
    rsync \
    unzip \
    yarn \
    sed \
    bash \
    zip \
    xmlstarlet \
    libltdl7 \
    bzip2 \
    openconnect \
    sudo \
    jq \
    rename \
    libglib2.0-0 \
    google-chrome-stable \
    mono-devel \
    kubectl \
    python3-pip \
    && rm -rf  /var/lib/apt/lists/*



RUN curl -sSL https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz \
		| tar -v -C /usr/local -xz

RUN easy_install -U pip \
    && pip install -U crcmod PyYAML requests

# install node version manager "n"
RUN curl -L https://git.io/n-install | bash -s -- -y


RUN addgroup --system -gid 10000 jenkins
RUN adduser --uid 10000 --home $HOME --ingroup jenkins jenkins

#add docker support for jenkins user
RUN addgroup --system -gid 999 docker && usermod -aG docker jenkins

RUN chown -R jenkins $HOME

RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER jenkins

WORKDIR $HOME

RUN echo PATH=\$PATH:/usr/local/go/bin >> .bashrc

RUN wget -qO /tmp/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_SLAVE_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

ENTRYPOINT ["jenkins-slave.sh"]