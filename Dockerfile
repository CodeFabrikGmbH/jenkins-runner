FROM ubuntu:22.04

ARG JENKINS_SLAVE_VERSION=3.17
ENV HOME /home/jenkins

# enable apt/https (for adding google cloud repo)
RUN apt-get update && apt-get install -y apt-transport-https curl wget && rm -rf  /var/lib/apt/lists/*

# add google cloud repo
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk -y

# add yarn repo
RUN apt-get update && apt-get install -y gnupg2
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# prepare installation of chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list

# prepare mono installation
RUN apt-get update && apt install -y dirmngr gnupg ca-certificates software-properties-common && rm -rf  /var/lib/apt/lists/*
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN apt-add-repository 'deb https://download.mono-project.com/repo/ubuntu stable-focal main'

RUN apt-get update \
    && apt-get install -y --allow-unauthenticated \
    gcc python3-venv python3-pip \
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
    mono-complete \
    nodejs \
    npm \
    && rm -rf  /var/lib/apt/lists/*



RUN curl -sSL https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz \
		| tar -v -C /usr/local -xz

RUN pip install -U crcmod

# install node version manager "n"
RUN npm install -g n

RUN set -eux; \
    ESUM='acc7a6aabced44e62ec3b83e3b5959df2b1aa6b3d610d58ee45f0c21a7821a71'; \
    BINARY_URL='https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_linux-x64_bin.tar.gz'; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/jvm/jdk13.0.2; \
    cd /opt/jvm/jdk13.0.2; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

RUN addgroup --system -gid 1000 jenkins
RUN adduser --uid 1000 --home $HOME --ingroup jenkins jenkins

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
