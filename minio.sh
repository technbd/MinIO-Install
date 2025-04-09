#!/bin/bash

export MINIO_ROOT_USER=minio
export MINIO_ROOT_PASSWORD=minio@dmin

#/opt/minio/bin/minio server /minio/data --address :9000
/opt/Minio/bin/minio server /opt/Minio/data --console-address :9001

### Or:###

#MINIO_ROOT_USER=minio MINIO_ROOT_PASSWORD=minio@dmin /opt/Minio/bin/minio server /opt/Minio/data --console-address :9001

