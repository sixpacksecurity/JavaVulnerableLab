FROM tomcat

RUN apt-get update ; apt-get upgrade -y 

RUN cp target/*.war /usr/local/tomcat/webapps/

CMD ["catalina.sh","run"]
