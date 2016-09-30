#!/bin/bash

#This Script will sign a client / server certificate request and produce the certificate

#NEED TO MODIFY TO ACCEPT MULTIPLE DOMAINS. WILL APPEND TO .CNF FILE

#Check if certificate workspace directory and intermediatory directory (where signing will take place) is provided
if [[ -z $1 ]] || [[ -z $2 ]]; then
	echo "**********************************************************************"
	echo "Must Provide the Server Cert Request Dir and the Intermediatory CA Dir"
	echo "**********************************************************************"
	exit 1
fi

CNNAME=$1
INTERDIR=$2

#Verify required directories exist
if [[ ! -d workspace/$CNNAME ]]; then
	echo "***************************************"
	echo "$CNNAME for Server Cert Request Invalid"
	echo "***************************************"
	exit 1
elif [[ ! -d workspace/$INTERDIR ]]; then
	echo "*****************************************"
	echo "$INTERDIR for Intermediatory Cert Invalid"
	echo "*****************************************"
	exit 1
fi

echo "**********************************"
echo "Signing Server Certificate Request"
echo "**********************************"

cd workspace/$INTERDIR
openssl ca -config ${INTERDIR}.cnf -extensions server_cert -days 375 -notext -md sha256 -in ../../workspace/${CNNAME}/${CNNAME}.csr.pem -out ../../workspace/${CNNAME}/${CNNAME}.cert.pem
chmod 444 ../../workspace/${CNNAME}/${CNNAME}.cert.pem

#verify the server certificate
echo ""
echo "*****************************"
echo "Verify the Server Certificate"
echo "*****************************"
openssl x509 -noout -text -in ../../workspace/${CNNAME}/${CNNAME}.cert.pem

cat ../../workspace/${CNNAME}/${CNNAME}.cert.pem certs/${INTERDIR}-chain.cert.pem > ../../workspace/${CNNAME}/${CNNAME}-chain.cert.pem
echo ""
echo "********************************"
echo "Server Certificate Chain Created"
echo "********************************"

#verify the intermediate certificate against root certificate
echo ""
echo "****************************************************************************"
echo "Verify the Server Certificate against the Intermediate Certificate Authority"
echo "****************************************************************************"
openssl verify -CAfile certs/${INTERDIR}-chain.cert.pem ../../workspace/${CNNAME}/${CNNAME}.cert.pem
openssl verify -CAfile certs/${INTERDIR}-chain.cert.pem ../../workspace/${CNNAME}/${CNNAME}-chain.cert.pem
