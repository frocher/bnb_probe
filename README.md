## The BotnBot Probe

The Botnbot Probe is a standalone application that returns different statistics about an url.

You can request statistics about a given url with a HTTP command like this : http://localhost:3333/check?url=https://www.github.com.
You can also request a simple uptime monitoring with something like this : http://localhost:3333/uptime?url=https://www.github.com

### Dependencies

This application is written with Ruby on Rails and uses different tools :

* Node.js: for Browsertime
* Ruby 2.3: for Ror
* curl: for uptime monitoring
* Browsertime: the great tool that does all the heavy work (http://tobli.github.io/browsertime/)
* Google Chrome and Google Chrome Driver : if you want to use Chrome as your test browser
* Firefox : if you want to use Firefox as your test browser


### Quickstart (without Docker)

You'll need to install a lot of things. Just look at the Dockerfile to see what to do.

```sh
bundle install
rails s -b 0.0.0.0
```

### Quickstart (the Docker way)

```sh
docker run -p 3333:3000 -d probe bundle exec rails s -p 3000
```

or if docker-compose is installed

```sh
docker-compose build
docker-compose up
```



### Configuration

the BotnBot Probe uses the following environment variables :

* PROBE_BROWSER : name of the browser to use for statistics checks. Default is 'chrome' but you can also use 'firefox'.
