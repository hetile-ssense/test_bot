# hubot-salty

This is a coffee.script for hubot and slack. It's puprose is to be a slack's interface to salt API.

### Installation

hubot-salty require these module to be installed:

* gcc 
* libffi-devel 
* python-devel 
* openssl-devel 
* python2-pip 
* nodejs 
* npm

Install them using:

```
sudo yum -y install gcc libffi-devel python-devel openssl-devel python2-pip nodejs npm
```

hubot also require an up-to-date [Python Package Index](https://pypi.python.org/pypi/pip) and the [CherryPy](http://cherrypy.org/) package.
```
sudo pip install --upgrade pip cherrypy
```

Once everything is setup, run the hubot generator

```
sudo npm install -g yo generator-hubot
```

And create the bot:
```
yo hubot --name=salty --owner=aa@aa.com --description='Une belle desc' --adapter=slack
```

### Config

In the boot.sh file, you will find some configuration variable that are required in order to connect to slack and connect to SALT-API.

| Variable | description |
| ------ | ------ |
|HUBOT_SLACK_TOKEN| This is slack API Token required to connect to slack service. [Create one](https://slack.com/apps/A0F7XDU93-hubot)|
|SALT_API_URL|URL to salt api (most likely: http://localhost:8000)|
|SALT_OUTPUT_CHANNEL|Channel where to output API result|
|SALT_LISTEN|Channel where command are issued by users|
|HUBOT_SLACK_CHANNELS|List of channel to join when connecting|

### Notes

The REST cherrypy must be activated in /etc/salt/master.  Exemple:
```
rest_cherrypy:
  port: 8000
  disable_ssl: true
```

Access to different module are controled directly in /etc/salt/master file. Exemple: 

```
external_auth:
  pam:
   salt-api-user:
     - test.*
     - state.apply
     - grains.*
     - status.*
     - system.*
     - '@runner'
```
