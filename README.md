** Nagios 4 docker build **

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
