# About the Project

CertGen is a collection of bash scripts that help generate SSL certificates. So far scripts can generate root key / cert pairs and intermediatory key / cert pairs for signing certs, csr requests for server certificates and signing
of server certs via the intermediatory cert

# Planned Enhancements

* Allow for exclusion of intermediatory key / certs or multiple hierarchy of intermediatory key / certs. So far only 3 fixed levels supported
* Allow gencertreq.sh to take in a list of alternate domains to be applied to the certificate request
* Allow gencertreq.sh to specify whether this is a client or server certificate request

# Run Instructions

* To generate a root key / cert pair
* ./genrootca.sh <root dir>

* To generate a intermediate key / cert pair signed by the root CA
* ./genintermediateca.sh <rootdir (must already exist)> <intermediatory dir>

* To generate a server key / cert request signed by an intermediatory CA
* ./gencertreq.sh <server dir (will default to CN name)>
