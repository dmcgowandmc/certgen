#!/bin/bash

#This Script will generate a root CA and Key

ROOTDIR="rootca"

#Setup directory structure
if [[ -d $ROOTDIR ]]; then
	echo "*****************************"
	echo "Recreating $ROOTDIR Structure"
	echo "*****************************"
        rm -R $ROOTDIR
else
	echo "***************************"
	echo "Creating $ROOTDIR Structure"
	echo "***************************"
fi

mkdir $ROOTDIR
cp rootca.cnf $ROOTDIR
cd $ROOTDIR
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

#generate the root private key. Will be prompted for password
echo ""
echo "*******************************"
echo "Generating the root Private Key"
echo "*******************************"

openssl genrsa -aes256 -out private/rootca.key.pem 4096
chmod 400 private/rootca.key.pem

#generate the root certificate authority
echo ""
echo "*****************************************"
echo "Generating the root Certificate Authority"
echo "*****************************************"
openssl req -config rootca.cnf -key private/rootca.key.pem -new -x509 -days 3750 -sha256 -extensions v3_ca -out certs/rootca.cert.pem

#verify the root certificate authority
echo ""
echo "*************************************"
echo "Verify the root Certificate Authority"
echo "*************************************"
openssl x509 -noout -text -in certs/rootca.cert.pem
