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

RUN chown -R jenkins $HOME

RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER jenkins

WORKDIR $HOME

RUN echo PATH=\$PATH:/usr/local/go/bin >> .bashrc

RUN wget -qO /tmp/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_SLAVE_VERSION}/remoting-${JENKINS_SLAVE_VERSION}.jar

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

ENTRYPOINT ["jenkins-slave.sh"]
