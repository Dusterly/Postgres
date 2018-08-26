#!/bin/bash
function echo_colored {
	local color=$1
	local text=$2
	echo "\033[${color}m" #]
	echo "$text"
	echo "\033[0m" #]
}

function display_result {
	local red=31
	local green=32
	if [[ $1 = 0 ]]; then
		echo_colored $green "😍  SUCCESS 😍"
	else
		echo_colored $red "🤕  FAILURE 🤕"
	fi
}

if [[ "$(docker image ls -q psql_dev 2> /dev/null)" == "" ]]; then
	docker build -f psql_dev.dockerfile -t psql_dev .
fi

docker build -t pg_test -f test.dockerfile . && \
docker run \
	--name pg_test \
	--link firefly:postgres \
	-e firefly_postgres_host=postgres \
	-e firefly_postgres_database=postgres \
	-itd pg_test \
	bash && \
docker start pg_test && \
docker exec pg_test swift test -c release

result=$?
display_result $result

docker container stop pg_test > /dev/null
docker container rm pg_test > /dev/null
docker image rm pg_test > /dev/null
