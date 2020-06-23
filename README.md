# bbb-lti-run

This document provides instructions on how to deploy bbb-lti-broker + bbb-app-rooms using postgres and behind a nginx proxy using docker-compose.


## Prerequisites

- Install
[docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04)
  and
[docker-compose](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04)

- Make sure you have your own DNS and a public domain name or a delegated one under blindside-dev.com
  (e.g. <JOHN>.blindside-dev.com)

## Preliminary steps

Start by setting up your DNS. It can be done using [Google Cloud DNS](https://console.cloud.google.com/net-services/dns/zones) or [AWS Route 53](https://console.aws.amazon.com/route53/).

Add a new zone `<JOHN>.blindside-dev.com` and give the values in the `NS` record to `blindside-dev.com` administrator. E.g.

```
<JOHN>.blindside-dev.com.   NS   ns-169.awsdns-21.com.                 60
                                 ns-1089.awsdns-08.org.
                                 ns-544.awsdns-04.net.
                                 ns-1755.awsdns-27.co.uk.
```

Add entries for all your services 'gl', 'gll', 'lb5', 'rs' and possibly 'bbb' if you are using your own BigBlueButton server.

The DNS should look something like this:

```
<JOHN>.blindside-dev.com.        A       <YOUR_IP_ADDRESS>.            60
bbb.<JOHN>.blindside-dev.com.    A       <YOUR_BBB_IP_ADDRESS>.        60
lti.<JOHN>.blindside-dev.com.    CNAME   <JOHN>.blindside-dev.com.     60
```

### Notes on common issues (for rockies)
* Make sure no to use localhost or 127.0.0.x as YOUR_IP_ADDRESS because it won't work!, use you own machine real IP_ADDRESS instead
* By default, entries in the DNS will be created with a TTL too long for development. You want to keep it as short as possible
as this will give you flexibility if you need to update the entry. If you left the long TTL (6 hours), the entry will be cached and you
will have to wait 6 hours for the changes to be propagated. Normally good for production, but pretty bad for development.
* You can also hard code the entries in your `/etc/hosts` file. But you would have to do so into the containers.

## Steps

### Preliminary

* Clone this repository:

```
git clone git@github.com:blindsidenetworks/bbb-lti-run.git
cd bbb-lti-run
```

* Edit the `.env` file located in the root of the project

```
cp dotenv .env
vi .env
```

You will normally only need to replace `HOST_NAME`.

* Edit the `broker/.env` file and replace the following default values.

```
cp broker/dotenv broker/.env
vi .env
```


SECRET_KEY_BASE is the Ruby On Rails secret key and must be replaced with a random one. You can generate a suitable secret using `openssl rand -hex 32`.


* Edit the `rooms/.env` file and replace the following default values.

```
cp rooms/dotenv rooms/.env
vi .env
```

SECRET_KEY_BASE is the Ruby On Rails secret key and must be replaced with a random one. You can generate a suitable secret using `openssl rand -hex 32`.

RELATIVE_URL_ROOT is the relative root for Rooms, it is required as is (for now), and it is by default set to `apps`

BIGBLUEBUTTON_ENDPOINT  the BigBlueButton Endpoint to the server linked to this application.
BIGBLUEBUTTON_SECRET=8cd8ef52e8e101574e400365b55e11a6 the BigBlueButton Secret.
BIGBLUEBUTTON_MODERATOR_ROLES=Instructor,Faculty,Teacher,Mentor,Administrator,Admin

OMNIAUTH_BBBLTIBROKER_SITE Should match the values set up for the broker URL_HOST
OMNIAUTH_BBBLTIBROKER_ROOT Should match the values set up for the broker RELATIVE_URL_ROOT
OMNIAUTH_BBBLTIBROKER_KEY and OMNIAUTH_BBBLTIBROKER_SECRET Should match the values used when adding the app to the broker.


### Generating LetsEncrypt SSL Certificate Automatically

For using a SSL certificate signed by Let’s Encrypt, generate the certificates simply execute the command:

```
./init-letsencrypt.sh
```

Note that for the automatic method to work, the server where you are installing the certificate must be publicly available to the Internet.


### Generating LetsEncrypt SSL Certificate Manually

Create your own SSL Letsencrypt certificates. If you are going to
have this deployment running on your own computer (or in a private VM), you
need to generate the SSL certificates with certbot manually by adding the
challenge to your DNS.

Install letsencrypt in your own computer

```
sudo apt-get update
sudo apt-get -y install letsencrypt
```

Make yourself root

```
sudo -i
```

Start creating the certificates

```
certbot certonly --manual -d lti.<JOHN>.blindside-dev.com --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges=dns --email hostmaster@blindsdie-dev.com --server https://acme-v02.api.letsencrypt.org/directory
```

You will see something like this
```
-server https://acme-v02.api.letsencrypt.org/directory
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None
Obtaining a new certificate
Performing the following challenges:
dns-01 challenge for gl.<JOHN>.blindside-dev.com
dns-01 challenge for gl.<JOHN>.blindside-dev.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.gl.<JOHN>.blindside-dev.com with the following value:

2dxWYkcETHnimmQmCL0MCbhneRNxMEMo9yjk6P_17kE

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue
```

Create a TXT record in your DNS for
`_acme-challenge.lti.<JOHN>.blindside-dev.com` with the challenge string as
its value `2dxWYkcETHnimmQmCL0MCbhneRNxMEMo9yjk6P_17kE`

Copy the certificates to your bbb-lti-run directory. Although `/etc/letsencrypt/live/`
holds the latest certificate, they are only symbolic links. The real files must be copied too.

```
mkdir -p data/certbot/conf/archive
mkdir -p data/certbot/conf/live
cp -R /etc/letsencrypt/archive/lti.<JOHN>.blindside-dev.com <YOUR ROOT>/bbb-lti-run/data/certbot/conf/archive
cp -R /etc/letsencrypt/live/lti.<JOHN>.blindside-dev.com <YOUR ROOT>/bbb-lti-run/data/certbot/conf/live
```

And finally, start your environment with docker-compose

```
cd <YOUR ROOT>/bbb-lti-run
docker-compose up
```

If everything goes well, you will see all the containers starting and at the
end you will have access the bbb-lti-broker through:

```
https://lti.<JOHN>.blindside-dev.com/
```

You can see bbb-app-rooms at

```
https://lti.<JOHN>.blindside-dev.com/apps/rooms
```


## Exceptions

### LTI applications must be manually added to the broker

There are some rake tasks that can be used for managing applications and keys in
the BBB LTI broker.

```
docker exec -t broker bundle exec rake --tasks
docker exec -t broker bundle exec rake db:keys:showall
docker exec -t broker bundle exec rake db:keys:add[key1,secret1]
docker exec -t broker bundle exec rake db:apps:showall
docker exec -t broker bundle exec rake db:apps:add[rooms,b21211c29d27,3590e00d7ebd,https://lti.<JOHN>.blindside-dev.com/apps/rooms/auth/bbbltibroker/callback]
```

Although, for seeding the application with initial values, the files

it can also be executed:

```
docker exec -t broker bundle exec rake db:seed
```

For this, the values used for OMNIAUTH_BBBLTIBROKER_KEY and OMNIAUTH_BBBLTIBROKER_SECRET should match the values in the seed for uid and secret respectively.

```
vi broker/seeds.rb
```

### The DOMAINNAME is updated after the application starts
It is important to note that if the DOMAINNAME is updated after the
application was run, the launcher will have a reference to the old domain
as for the callbacks when using an external authentication system. In such
cases the easiest way to overcome the issue is to recreate the database.

```
docker ps
```

Will return something like this:

```
CONTAINER ID        IMAGE                                 COMMAND                  CREATED             STATUS              PORTS                                      NAMES
2642896703a1        nginx                                 "/bin/bash -c 'envsu…"   25 minutes ago      Up 25 minutes       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx
7d1b913aad6e        bigbluebutton/bbb-app-rooms:latest    "scripts/start.sh"       25 minutes ago      Up 25 minutes       0.0.0.0:3002->3000/tcp                     rooms
b552ed1b3db6        bigbluebutton/bbb-lti-broker:latest   "scripts/start.sh"       25 minutes ago      Up 25 minutes       0.0.0.0:3001->3000/tcp                     broker
a41613dfa428        postgres:9.5-alpine                   "docker-entrypoint.s…"   25 minutes ago      Up 25 minutes       0.0.0.0:5432->5432/tcp                     postgres
```

Use the CONTAINER_ID to execute terminal commands.

```
docker exec -t broker DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:drop
docker exec -t broker DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:setup
```

It may be necessary to interrupt docker-compose and execute a
`docker-compose down` and then `docker-compose up` to clean up what is left
