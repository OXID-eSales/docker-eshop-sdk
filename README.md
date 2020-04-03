# OXID eShop dev env based on docker

![Docker](/assets/docker-vector-logo.svg?raw=true&sanitize=true "Docker")

This docker based development environment may be used for local OXID eShop development and not for production.

## Dependencies

This developement environment assumes you have

- `docker` up and running
- a recent version of `docker-compose` installed
- support for `Makefile`

## Usage

### Install

```bash
$ git clone git@github.com:OXID-eSales/docker-eshop-sdk.git
$ cd docker-eshop-sdk
$ make init
```

### Access the Demoshop

* Shop: http://oxideshop.localhost/
* Administration: http://oxideshop.localhost/admin/
  * User: `admin`
  * Password: `admin`

### Access the Selenium Desktop

With any VNC viewer open up `localhost`, the password is `secret`.

### Run Tests

#### All tests

```bash
$ make test
```

#### Only integration and unit tests

```bash
$ docker-compose exec php ./vendor/bin/runtests
```

#### Only acceptance tests

```bash
$ docker-compose exec php ./vendor/bin/runtests-selenium
```

#### Code Coverage report

```bash
$ make coverage
```

### Using `composer`

Example usage:

```bash
$ docker-compose exec php composer -V
$ docker-compose exec php composer why oxid-esales/oxideshop-composer-plugin
```

### Using xDebug

The profiles and traces from xDebug will be dumped to `data/oxideshop/debug/` directory

## Troubleshooting

### Permission problems

When you see `composer install` or `composer update` failing due to permission problems, it might be that your `HOST_USER_ID` and `HOST_GROUP_ID` values in `.env` file are wrong. The `make  init` step tries to use the `/usr/bin/id` command to get the correct values, but could fail doing so.

To recover from this you need to set the correct `HOST_USER_ID` and `HOST_GROUP_ID` values in `.env` file and then `docker-composer build --no-cache` to enforce a rebuild of the container.

### Port conflicts

If any ports are already in use on your host you might need to change the bindings in the "ports:" section of the affected service.
For more details about the syntax see https://docs.docker.com/compose/compose-file/#ports.
