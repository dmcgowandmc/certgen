#!/bin/bash

#This Script will generate a intermediate CA signed by the root Key

ROOTDIR="rootca"

#Check if root DIR exists. If it doesn't exist, we need to exit (better error checking is eventually required)
if [[ ! -d $ROOTDIR ]]; then
	echo "*********************************************************************************************************"
	echo "No root Directory found. Please snure you have run the rootcagen.sh to produce a root key and certificate"
	echo "*********************************************************************************************************"
	exit 1
fi

#Setup intermediate directory structure
if [[ -d $ROOTDIR/intermediate ]]; then
	echo "*****************************"
	echo "Recreating $ROOTDIR/intermediate Structure"
	echo "*****************************"
        rm -R $ROOTDIR/intermediate
else
	echo "***************************"
	echo "Creating $ROOTDIR/intermediate Structure"
	echo "***************************"
fi

mkdir $ROOTDIR/intermediate
cp intermediateca.cnf $ROOTDIR/intermediate
cd $ROOTDIR/intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

#generate the intermediate private key. Will be prompted for password
echo ""
echo "***************************************"
echo "Generating the intermediate Private Key"
echo "***************************************"

openssl genrsa -aes256 -out private/intermediateca.key.pem 4096
chmod 400 private/intermediateca.key.pem

#generate the intermediate certificate request
echo ""
echo "*********************************************************"
echo "Generating the intermediate Certificate Authority Request"
echo "*********************************************************"
openssl req -config intermediateca.cnf -new -sha256 -key private/intermediateca.key.pem -out csr/intermediateca.csr.pem

#sign the intermediate certificate authority request
echo ""
echo "******************************************************"
echo "Signing the intermediate Certificate Authority Request"
echo "******************************************************"
cd ..
openssl ca -config rootca.cnf -extensions v3_intermediate_ca -days 3750 -notext -md sha256 -keyfile private/rootca.key.pem -cert certs/rootca.cert.pem -in intermediate/csr/intermediateca.csr.pem -out intermediate/certs/intermediateca.cert.pem

#verify the root certificate authority
#echo ""
#echo "*************************************"
#echo "Verify the root Certificate Authority"
#echo "*************************************"
#openssl x509 -noout -text -in certs/rootca.cert.pem
