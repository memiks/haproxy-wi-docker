FROM centos
MAINTAINER Memiks (https://github.com/memiks/haproxy-wi)

COPY epel.repo /etc/yum.repos.d/epel.repo
COPY haproxy-wi.conf /etc/httpd/conf.d/haproxy-wi.conf
COPY wrapper.sh /wrapper.sh

RUN dnf -y install git nmap-ncat net-tools python python-dev dos2unix httpd \
        gcc-c++ gcc gcc-gfortran openldap-devel && \
        git clone https://github.com/Aidaho12/haproxy-wi.git /var/www/haproxy-wi && \
        mkdir /var/www/haproxy-wi/keys/ && \
        mkdir /var/www/haproxy-wi/app/certs/ && \
        chown -R apache:apache /var/www/haproxy-wi/ && \
        pip install -r /var/www/haproxy-wi/requirements.txt --no-cache-dir && \
        chmod +x /var/www/haproxy-wi/app/*.py && \
        chmod +x /var/www/haproxy-wi/app/tools/*.py && \
        chmod +x /wrapper.sh && \
        chown -R apache:apache /var/log/httpd/ && \
        dnf -y erase git python python-dev platform-python-pip gcc-c++  gcc-gfortran gcc --remove-leaves && \
        dnf clean all && \
        rm -rf /var/cache/dnf && \
        rm -f /etc/yum.repos.d/* && \
        cd /var/www/haproxy-wi/app && \
        ./create_db.py && \
        chown -R apache:apache /var/www/haproxy-wi/

EXPOSE 80
VOLUME /var/www/haproxy-wi/

CMD /wrapper.sh
