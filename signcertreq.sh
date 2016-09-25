#!/bin/bash

#This Script will sign a client / server certificate request and produce the certificate

#NEED TO MODIFY TO ACCEPT MULTIPLE DOMAINS. WILL APPEND TO .CNF FILE

#Check if certificate workspace directory, root directory and intermediatory directory (where signing will take place) is provided
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then
	echo "***************************************************************************************"
	echo "Must Provide the Server Cert Request Dir, the Root CA Dir and the Intermediatory CA Dir"
	echo "***************************************************************************************"
	exit 1
fi

CNNAME=$1
ROOTDIR=$2
INTERDIR=$3

#Verify required directories exist
if [[ ! -d workspace/$CNNAME ]]; then
        echo "***************************************"
        echo "$CNNAME for Server Cert Request Invalid"
        echo "***************************************"
	exit 1
elif [[ ! -d workspace/$ROOTDIR ]]; then
        echo "*************************************************"
        echo "$ROOTDIR for Intermediatory Cert Location Invalid"
        echo "*************************************************"
	exit 1
elif [[ ! -d workspace/$ROOTDIR/workspace/$INTERDIR ]]; then
	echo "*****************************************"
        echo "$INTERDIR for Intermediatory Cert Invalid"
        echo "*****************************************"
        exit 1
fi

echo "**********************************"
echo "Signing Server Certificate Request"
echo "**********************************"

cd workspace/${ROOTDIR}/workspace/${INTERDIR}
openssl ca -config ${INTERDIR}.cnf -extensions server_cert -days 375 -notext -md sha256 -in ../../../${CNNAME}/${CNNAME}.csr.pem -out ../../../${CNNAME}/${CNNAME}.cert.pem
chmod 444 ../../../${CNNAME}/${CNNAME}.cert.pem

##ADD CODE TO CREATE FULL CHAIN
