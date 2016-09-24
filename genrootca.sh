#!/bin/bash

#This Script will generate a root CA and Key

#Check if a root directory name has been provided. Exit if not provided
if [[ -z $1 ]]; then
	echo "**************************************************************************"
	echo "You must enter a name for the root dir (which will default as the CN name)"
	echo "**************************************************************************"
	exit 1
fi

ROOTDIR=$1

#Setup directory structure
if [[ -d workspace/$ROOTDIR ]]; then
	echo "*****************************"
	echo "Recreating $ROOTDIR Structure"
	echo "*****************************"
        rm -R workspace/$ROOTDIR
else
	echo "***************************"
	echo "Creating $ROOTDIR Structure"
	echo "***************************"
fi

mkdir -p workspace
mkdir workspace/$ROOTDIR
sed s/REPLACE/$ROOTDIR/g rootca.cnf > workspace/${ROOTDIR}/${ROOTDIR}.cnf
cd workspace/$ROOTDIR
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

#generate the root private key. Will be prompted for password
echo ""
echo "*******************************"
echo "Generating the root Private Key"
echo "*******************************"

openssl genrsa -aes256 -out private/${ROOTDIR}.key.pem 4096
chmod 400 private/${ROOTDIR}.key.pem

#generate the root certificate authority
echo ""
echo "*****************************************"
echo "Generating the root Certificate Authority"
echo "*****************************************"
openssl req -config ${ROOTDIR}.cnf -key private/${ROOTDIR}.key.pem -new -x509 -days 3750 -sha256 -extensions v3_ca -out certs/${ROOTDIR}.cert.pem

#verify the root certificate authority
echo ""
echo "*************************************"
echo "Verify the root Certificate Authority"
echo "*************************************"
openssl x509 -noout -text -in certs/${ROOTDIR}.cert.pem
