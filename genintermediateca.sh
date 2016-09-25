#!/bin/bash

#This Script will generate a intermediate CA signed by the root Key

#Check if root directory and intermediate directory provided and that root directory actually exists
if [[ -z $1 ]] || [[ -z $2 ]]; then
	echo "**********************************************************"
	echo "Root Directory and Intermediate Directory must be provided"
	echo "**********************************************************"
	exit 1
fi

ROOTDIR=$1
INTERDIR=$2

#Check if root DIR exists. If it doesn't exist, we need to exit (better error checking is eventually required)
if [[ ! -d workspace/$ROOTDIR ]]; then
	echo "***********************************************************************************************"
	echo "No root Directory found. Please ensure you specify a valid root directory or generate a new one"
	echo "***********************************************************************************************"
	exit 1
fi

#Setup intermediate directory structure
if [[ -d workspace/$ROOTDIR/workspace/$INTERDIR ]]; then
	echo "*************************************************"
	echo "Recreating $ROOTDIR/workspace/$INTERDIR Structure"
	echo "*************************************************"
        rm -R workspace/$ROOTDIR/workspace/$INTERDIR
else
	echo "***********************************************"
	echo "Creating $ROOTDIR/workspace/$INTERDIR Structure"
	echo "***********************************************"
fi

mkdir -p workspace/$ROOTDIR/workspace
mkdir workspace/$ROOTDIR/workspace/$INTERDIR
sed s/REPLACE/$INTERDIR/g intermediateca.cnf > workspace/${ROOTDIR}/workspace/${INTERDIR}/${INTERDIR}.cnf
cd workspace/$ROOTDIR/workspace/$INTERDIR
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

openssl genrsa -aes256 -out private/${INTERDIR}.key.pem 4096
chmod 400 private/${INTERDIR}.key.pem

#generate the intermediate certificate request
echo ""
echo "*********************************************************"
echo "Generating the Intermediate Certificate Authority Request"
echo "*********************************************************"
openssl req -config ${INTERDIR}.cnf -new -sha256 -key private/${INTERDIR}.key.pem -out csr/${INTERDIR}.csr.pem

#sign the intermediate certificate authority request
echo ""
echo "******************************************************"
echo "Signing the Intermediate Certificate Authority Request"
echo "******************************************************"
cd ../..
openssl ca -config ${ROOTDIR}.cnf -extensions v3_intermediate_ca -days 3750 -notext -md sha256 -in workspace/${INTERDIR}/csr/${INTERDIR}.csr.pem -out workspace/${INTERDIR}/certs/${INTERDIR}.cert.pem
chmod 444 workspace/${INTERDIR}/certs/${INTERDIR}.cert.pem
cd workspace/$INTERDIR

#verify the intermediate certificate authority
echo ""
echo "*********************************************"
echo "Verify the Intermediate Certificate Authority"
echo "*********************************************"
openssl x509 -noout -text -in certs/${INTERDIR}.cert.pem

#verify the intermediate certificate against root certificate
echo ""
echo "************************************************************************************"
echo "Verify the Intermediate Certificate Authority against the Root Certificate Authority"
echo "************************************************************************************"
cd ../..
openssl verify -CAfile certs/${ROOTDIR}.cert.pem workspace/${INTERDIR}/certs/${INTERDIR}.cert.pem

#finally, create the intermediate certificate authority chain
echo ""
echo "***************************************************"
echo "Create the Intermediate Certificate Authority Chain"
echo "***************************************************"
cat workspace/${INTERDIR}/certs/${INTERDIR}.cert.pem certs/${ROOTDIR}.cert.pem > workspace/${INTERDIR}/certs/${INTERDIR}-chain.cert.pem
cd workspace/$INTERDIR
