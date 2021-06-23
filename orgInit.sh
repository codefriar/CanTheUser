#!/bin/bash

DURATION=7

if [ "$#" -eq 1 ]; then
  DURATION=$1
fi

sfdx force:org:create -f config/project-scratch-def.json --setalias $(git symbolic-ref --short -q HEAD) --durationdays 7 --setdefaultusername --json --loglevel fatal
sfdx force:source:push
sfdx force:org:open
echo "Org is set up"