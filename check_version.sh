#! /bin/bash

set -e

myVersion=CHECK_VERSION_IN_BRANCH_PROD

code=0

if [ $# -ne 2 ]
then
  echo "Illegal number of parameters."
  echo "./check_version.sh <docker_user> <docker_pass>"
  exit 10
fi

# Check if 'curl' is installed.
if ! command -v curl &> /dev/null
then
    echo "'curl' could not be found."
    exit 10
fi

# Check if 'jq' is installed.
if ! command -v jq &> /dev/null
then
    echo "'jq' could not be found."
    exit 10
fi


##########
# update #
##########
update=$(curl -s https://raw.githubusercontent.com/edufolly/docker-image-tag-check/prod/VERSION.txt | head -n 1 | cut -f 2 -d '=')

if [ "${myVersion}" != "${update}" ]
then
  echo ""
  echo "[UPDATE] We've a new version: $update"
  echo "https://raw.githubusercontent.com/edufolly/docker-image-tag-check/"
  echo ""
fi


###########
# git tag #
###########
git fetch --tags --depth=1 origin &> /dev/null

branch=$(git rev-parse --abbrev-ref HEAD)

suffix=""

case $branch in
  alpha) suffix="A" ;;
  beta) suffix="B" ;;
  dev) branch="main" ;;
esac

version=$(grep 'VERSION=' VERSION.txt | head -n 1 | cut -f 2 -d '=')$suffix

if git rev-parse "v$version^{tag}" >/dev/null 2>&1
then
  echo "[ERROR] Tag v$version already deployed."
  code=20
else
  echo "Tag v$version is ready to deploy."
fi
echo ""


################
# docker login #
################
dockeruser=$1
dockerpass=$2

dockerserver="https://hub.docker.com/v2"

token=$(curl -s -X POST -H 'Content-Type: application/json' -d '{"username":"'$dockeruser'","password":"'$dockerpass'"}' $dockerserver/users/login | jq --raw-output '.token')

if [ -z "$token" ]
then
  echo "Docker login error."
  exit 30
fi


##################
# docker-compose #
##################
for image in $(grep --line-buffered 'image:' docker-compose.yml)
do
  if [ "${image}" != "image:" ]
  then

    repo=${image%:*}
    
    tag=${image##*:}

    echo "Checking: $repo - $tag"

    if [[ "$repo" != *"/"* ]]
    then
      repo="library/$repo"
    fi

    check=$(curl -s -H "Authorization: Bearer $token" $dockerserver/repositories/$repo/tags/$tag | jq --raw-output '.name')

    if [ "${tag}" != "${check}" ]
    then
      echo "[ERROR] Local: $tag - Remote: $check"
      code=40
    else
      echo "Local: $tag - Remote: $check"
    fi

    echo ""
  fi
done

exit $code
