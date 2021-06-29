FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/
COPY run.sh /opt/
RUN ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && apt-get update \
    && apt install python3-dev python3-pip python3-virtualenv sqlitebrowser git expect -y \
    && git clone https://github.com/django-ve/django-helloworld.git \
    && cd django-helloworld && pip3 install -r requirements.txt \
    && python3 manage.py migrate && chmod +x /opt/run.sh  
RUN /opt/run.sh
ENTRYPOINT ["python3","manage.py","runserver"]
