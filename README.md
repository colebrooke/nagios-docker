Nagios 4 docker build 
---------------------

This project builds a container for nagios4, based on a standard Ubuntu 16:04 container.

Assuming you have docker set up on your local machine, you can follow these steps to build.
(Tested on OSX macbook)

``` 
# first cd to your project directory, then

$ docker build . -t nagios-docker
$ docker run -p 80:80 -d -t nagios-docker

# for debugging, you can get a terminal to the container:

$ docker ps  # note the container id
$ docker exec -it <container_id> bash
```

The container services should start automatically. You should then be able to access nagios via the IP of your local docker instance on port 80, e.g.

> http://192.168.99.1/nagios

The default username and password for the nagios http interface is set in the Dockerfile, as 

> username:  nagiosadmin
> password:  password


