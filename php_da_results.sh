#!/bin/bash

MAJOR_BRANCH=8.0

CCN_MAJOR_BRANCH=$(sed -rn 's|.*ccn2="([^"]*)".*|\1|p' summary_$MAJOR_BRANCH.xml | awk 'FNR == 1')
NPATH_MAJOR_BRANCH=$(sed -rn 's|.*npath="([^"]*)".*|\1|p' summary_$MAJOR_BRANCH.xml | awk '{total += $0} END{print total}')
NCLOC_MAJOR_BRANCH=$(sed -rn 's|.*ncloc="([^"]*)".*|\1|p' summary_$MAJOR_BRANCH.xml | awk 'FNR == 1')
CCPERKNCLOC_MAJOR_BRANCH=$(bc <<< "scale=10;($CCN_MAJOR_BRANCH/$NCLOC_MAJOR_BRANCH*1000)")
NPATHPERKNCLOC_MAJOR_BRANCH=$(bc <<< "scale=10;($NPATH_MAJOR_BRANCH/$NCLOC_MAJOR_BRANCH*1000)")

#export CCN_MAJOR_BRANCH
#export NPATH_MAJOR_BRANCH
#export NCLOC_MAJOR_BRANCH
#export CCPERKNCLOC_MAJOR_BRANCH
#export NPATHPERKNCLOC_MAJOR_BRANCH

DATA='Code Metrics: Cyclomatic Complexity Number: '$CCN_MAJOR_BRANCH' NPATH Complexity Sum: '$NPATH_MAJOR_BRANCH' Cyclomatic Complexity per 1000 NCLOC: '$(bc <<< "scale=2;$CCPERKNCLOC_MAJOR_BRANCH/1")' NPATH Complexity per 1000 NCLOC: '$(bc <<< "scale=2;$NPATHPERKNCLOC_MAJOR_BRANCH/1")''
echo "$DATA" > "./php_da.results.json"
