# docker-image-tag-check

A shell script to check if the images of docker compose exists.

Version: 0.0.3

**Attention**: This is a reference repository.

The `docker-compose.yml` is only an [example reference](https://github.com/taigaio/taiga-docker/blob/47c73d1a24a98f1d1200af4ff0abb96c18745e21/docker-compose.yml). 

</br>

## How to use

```shell
./check_version.sh <docker_user> <docker_token>
```

</br>

## Setting up GitHub Actions

Create this GitHub Action secrets:

 - `DOCKER_USERNAME` with the docker username.
 - `DOCKER_TOKEN` with the docker token.

Check the [`ci_build.yml`](https://github.com/edufolly/docker-image-tag-check/blob/main/.github/workflows/ci_build.yml) actions workflow for more details.

## Download

Download the latest script from [prod branch](https://raw.githubusercontent.com/edufolly/docker-image-tag-check/prod/check_version.sh).

```shell
wget -O check_version.sh https://raw.githubusercontent.com/edufolly/docker-image-tag-check/prod/check_version.sh

chmod a+x check_version.sh
```
