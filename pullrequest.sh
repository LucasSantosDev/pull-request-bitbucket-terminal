#!/bin/bash

#########################################
# Need install pack to handle with JSON #
#########################################
# Linux -> sudo apt-get install jq      #
# MacOS -> brew install jq              #
#########################################

# Command to RUN create PR
# sh pullrequest.sh

read -p "Enter title PR (default): " title
read -p "Enter description (optional): " description

current_branch="$(git branch --show-current)"

if [ "$title" = 'default' ];
then
        title=$current_branch
fi

cat pullrequest.json | \
        jq '.source.branch.name = $new_branch' --arg new_branch "$current_branch" | \
        jq '.destination.branch.name = $destination' --arg destination "$(git log --pretty=format:'%D' HEAD^ | grep 'origin/' | head -n1 | sed 's@origin/@@' | sed 's@,.*@@'
)" | \
        jq '.title = $title' --arg title "$title" | \
        jq '.description = $description' --arg description "$description" | \
        jq '.reviewers[0].username = $reviewer' --arg reviewer "nickname_reviewer" | \
        jq '.source.repository.full_name = $repository' --arg repository "$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')" > pullrequest_copy.json

rm pullrequest.json

mv pullrequest_copy.json pullrequest.json

curl -X POST -H "Content-Type: application/json" -u $(git config user.email) https://bitbucket.org/api/2.0/repositories/$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')/pullrequests -d @pullrequest.json
