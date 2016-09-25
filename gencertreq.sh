#!/bin/bash

#This Script will generate a client / server key and certificate request

#NEED TO MODIFY TO ACCEPT MULTIPLE DOMAINS. WILL APPEND TO .CNF FILE

#Check if certificate workspace directory is provided
if [[ -z $1 ]]; then
	echo "******************************"
	echo "Must Provide a Default CN name"
	echo "******************************"
	exit 1
fi

CNNAME=$1

#Setup request directory structure
if [[ -d workspace/$CNNAME ]]; then
        echo "****************************"
        echo "Recreating $CNNAME Structure"
        echo "****************************"
        rm -R workspace/$CNNAME
else
        echo "**************************"
        echo "Creating $CNNAME Structure"
        echo "**************************"
fi


mkdir -p workspace
mkdir workspace/${CNNAME}
sed s/REPLACE/$CNNAME/g server.cnf > workspace/${CNNAME}/${CNNAME}.cnf

#generate the server private key. Will be prompted for password
echo ""
echo "*********************************************************************"
echo "Generating the Server or Client Private Key (omitting -aes256 option)"
echo "*********************************************************************"

openssl genrsa -out workspace/${CNNAME}/${CNNAME}.key.pem 2048
chmod 400 workspace/${CNNAME}/${CNNAME}.key.pem

#generate the intermediate certificate request
echo ""
echo "***************************************************"
echo "Generating the Server or Client Certificate Request"
echo "***************************************************"
openssl req -config workspace/${CNNAME}/${CNNAME}.cnf -key workspace/${CNNAME}/${CNNAME}.key.pem -new -sha256 -out workspace/${CNNAME}/${CNNAME}.csr.pem
