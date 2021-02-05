FROM daocloud.io/library/java:8u40-b09
MAINTAINER JiYun Tech Team <mboss0@163.com>

ADD ./sources.list /etc/apt/sources.list
ADD ./Python-3.7.1.tgz /usr/local
RUN set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends  openssh-server tzdata && \
# 安装python依赖包	
	apt-get install -y gcc make wget && \
	apt-get install -y build-essential checkinstall && \
	apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev  libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev && \
	apt-get install -y build-essential python-dev python-setuptools python-pip python-smbus && \
	apt-get install -y build-essential libncursesw5-dev libgdbm-dev libc6-dev && \
	apt-get install -y zlib1g-dev libsqlite3-dev tk-dev && \
	apt-get install -y libssl-dev openssl && \
	apt-get install -y libffi-dev && \
	apt-get install -y espeak && \
	rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/* 
	
	
RUN set -ex \
	&& mkdir /usr/local/python3 \
	&& cd /usr/local \
	# && cd Python-3.7.1 && ls \
	# && tar -xzvf /usr/local/Python-3.7.1.tgz \
	&& cd /usr/local/Python-3.7.1 \
	&& ./configure prefix=/usr/local/python3 \
	&& make && make install \
	&& ln -s /usr/local/python3/bin/python3 /usr/local/bin/python3 \
	&& ln -s /usr/local/python3/bin/pip3 /usr/local/bin/pip3 \
	&& ln -s /usr/local/python3/bin/python3 /usr/bin/python3 \
	&& ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3 \
	&& pip3 -V && python3 -V \
	&& pip3 install pyttsx3 \
	&& mkdir /usr/ffmpeg

ADD ./ffmpeg-snapshot.tar.bz2 /usr/ffmpeg/	

RUN set -ex \
	&& apt-get update \
	# && tar -jxvf /usr/ffmpeg/ffmpeg-snapshot.tar.bz2 \
	&& cd /usr/ffmpeg/ffmpeg \
	&& apt-get install -y yasm \
	&& ./configure --enable-shared --prefix=/usr/ffmpeg \
	&& make && make install

ADD ./ld.so.conf   /etc/ld.so.conf
ADD ./profile   /etc/profile

RUN set -ex \
	&&  ldconfig \
	&&  ln -s /usr/ffmpeg/bin/ffmpeg /usr/local/bin/ 
	# &&  rm -rf /usr/local/Python-3.7.1.tgz \
	# &&  rm -rf /usr/ffmpeg/ffmpeg-snapshot.tar.bz2

# RUN /bin/bash -c "source /etc/profile"	
	
RUN mkdir /var/run/sshd && \
    rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone && \
    echo "Port 22" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    rm /etc/ssh/ssh_host_* && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

RUN echo "sshd:ALL" >> /etc/hosts.allow

RUN mkdir -p /var/www
VOLUME /var/www
WORKDIR /var/www

ENTRYPOINT ["/bin/bash", "/start.sh"]