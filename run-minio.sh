#!/bin/bash
export MINIO_HOME=/opt/Minio/bin
export MINIO_DATA=/opt/Minio/data
export MINIO_ADDRESS=0.0.0.0:9000
export MINIO_CONSOLE=0.0.0.0:9001

echo ""
echo "---------------------------------------"
echo "MinIO Home Directory: $MINIO_HOME"
echo "MinIO Data Directory: $MINIO_DATA"
echo "MinIO Access Address: $MINIO_ADDRESS"
echo "MinIO Console Address: $MINIO_CONSOLE"

echo "---------------------------------------"
echo ""


echo "Starting MinIO server..."
echo "---------------------------------------"
MINIO_ROOT_USER=minio MINIO_ROOT_PASSWORD=minio@dmin $MINIO_HOME/minio server $MINIO_DATA --address $MINIO_ADDRESS --console-address $MINIO_CONSOLE



