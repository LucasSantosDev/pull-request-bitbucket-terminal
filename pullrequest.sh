#!/bin/bash

#########################################
# Need install pack to handle with JSON #
#########################################
# Linux -> sudo apt-get install jq      #
# MacOS -> brew install jq              #
#########################################

# Command to RUN create PR
# sh pullrequest.sh development ´title´ ´descriprion´ (pode passar vazio também) -- modificar os ´ por aspas

cat pullrequest.json | \
	jq '.source.branch.name = $new_branch' --arg new_branch $(git branch --show-current) | \
	jq '.destination.branch.name = $destination' --arg destination "$1" | \
	jq '.title = $title' --arg title "$2" | \
	jq '.description = $description' --arg description "$3" | \
	jq '.source.repository.full_name = $repository' --arg repository "$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')" > pullrequest_copy.json

rm pullrequest.json

mv pullrequest_copy.json pullrequest.json

curl -X POST -H "Content-Type: application/json" -u $(git config user.email) https://bitbucket.org/api/2.0/repositories/$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')/pullrequests -d @pullrequest.json
