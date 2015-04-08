docker-haproxy-marathon
=======================

HAProxy image that provides discovery of marathon launched services in a mesos cluster
The configuration of HAProxy will be verified every second against Marathon API and if necessary refreshed

Usage
-----

Using docker:

	docker run --net=host -e MARATHON_HOSTS="marathon-master1-ipaddr:8080 marathon-master2-ipaddr:8080 ..." haproxy-marathon

Using Marathon REST API:

{
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "cmanzana/haproxy-marathon:latest",
      "network": "HOST"
    },
    "env": {
      "MARATHON_HOSTS": "marathon-master1-ipaddr:8080 marathon-master2-ipaddr:8080 ..."
    }
  },
  "id": "haproxy-marathon",
  "instances": 5,
  "cpus": 0.5,
  "mem": 512,
  "constraints": [["hostname", "UNIQUE"]]
}

Why would you want to use this container?
-----------------------------------------
If you deploy this container to every single slave in your mesos cluster then you only need to point your service requests to the host IP address where your container is running, the HAProxy container will take care of redirecting your request to the right IP address where the actual service container is running
