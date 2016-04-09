## The BotnBot Probe

The Botnbot Probe is a standalone application that returns different statistics about an url.

You can request statistics about a given url with a HTTP command like this : http://localhost:3333/check?url=https://www.github.com.
You can also request a simple uptime monitoring with something like this : http://localhost:3333/uptime?url=https://www.github.com

### Dependencies

This application is written with Ruby on Rails and uses different tools :

* Node.js: used by Browsertime (see below)
* Ruby 2.3: for [Ruby on Rails](http://rubyonrails.org/)
* curl: for uptime monitoring
* Browsertime: the great tool that does all the heavy work (http://tobli.github.io/browsertime/)
* Google Chrome and Google Chrome Driver : if you want to use Chrome as your test browser
* Firefox : if you want to use Firefox as your test browser


### Quickstart (without Docker)

You'll need to install a lot of things. Just look at the Dockerfile to see what to do (and good luck to you).


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
* PROBE_TOKEN : You can define a token to restrict access to the probe. If probe token is undefined, no access restriction is applied otherwise the token must be passed as a 'token' parameter.

This software uses the Figaro gem. you can define this variables using an application.yml file or using environment variables.

### API Documentation

#### Uptime

```sh
http://your_domain/uptime?url=<url>&token=<token>&keyword=<keyword>&type=<type>
```

| Param   | Mandatory | Description  |
| --------|:---------:| -----|
| url     | yes       | URL to check (e.g. http://www.google.com)|
| token   | no        | Secret token used to restrict access |
| keyword | no        | Check if a keyword is present or absent depending on the type parameter |
| type    | no        |  Can be 'presence' or 'absence'. Default is 'presence' |

#### Check

```sh
http://your_domain/check?url=<url>&token=<token>&target=<target>
```

| Param  | Mandatory | Description  |
| -------|:---------:| -----|
| url    | yes       | URL to check (e.g. http://www.google.com)|
| token  | no        | Secret token used to restrict access |
| target | no        | 'desktop' or 'mobile'. If desktop simulate a cable connection, if mobile a 3g connection. Default is 'desktop' |
