FROM centos
MAINTAINER Memiks (https://github.com/memiks/haproxy-wi)

COPY epel.repo /etc/yum.repos.d/epel.repo
COPY haproxy-wi.conf /etc/httpd/conf.d/haproxy-wi.conf
COPY wrapper.sh /wrapper.sh

RUN dnf -y install git nmap-ncat net-tools dos2unix httpd \
        gcc-c++ gcc gcc-gfortran openldap-devel
RUN dnf -y install platform-python platform-python-pip
RUN ln -s /usr/lib/python3.6/site-packages/pip /usr/bin/
RUN echo ${PATH}
RUN git clone https://github.com/Aidaho12/haproxy-wi.git /var/www/haproxy-wi && \
        mkdir /var/www/haproxy-wi/keys/ && \
        chown -R apache:apache /var/www/haproxy-wi/
RUN pip install -r /var/www/haproxy-wi/requirements.txt --no-cache-dir && \
        chmod +x /var/www/haproxy-wi/app/*.py && \
        chmod +x /var/www/haproxy-wi/app/tools/*.py && \
        chmod +x /wrapper.sh && \
        chown -R apache:apache /var/log/httpd/
RUN dnf -y erase git python python-dev platform-python-pip gcc-c++  gcc-gfortran gcc --remove-leaves && \
        dnf clean all
RUN rm -rf /var/cache/dnf && \
        rm -f /etc/yum.repos.d/*
RUN cd /var/www/haproxy-wi/app && \
        ./create_db.py && \
        chown -R apache:apache /var/www/haproxy-wi/

EXPOSE 80
VOLUME /var/www/haproxy-wi/

CMD /wrapper.sh
