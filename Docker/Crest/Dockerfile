FROM busybox

# Modified from https://github.com/crccheck/docker-hello-world

ADD https://raw.githubusercontent.com/crccheck/docker-hello-world/master/index.html /www/index.html

EXPOSE 8000

# Create a basic webserver and sleep forever
CMD httpd -p 8000 -h /www; tail -f /dev/null
