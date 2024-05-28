## Minio: 
MinIO is a high-performance, distributed object storage system designed for storing large amounts of unstructured data, such as photos, videos, log files, backups, and container/VM images. It is compatible with the Amazon S3 cloud storage service and supports all core S3 features, with providing a reliable and scalable storage solution for both cloud-native and on-premises environments.


### Storage Requirements:
The following requirements summarize the Storage section of MinIO’s hardware recommendations:

- `Use Local Storage`: Direct-Attached Storage (DAS) has significant performance and consistency advantages over networked storage (NAS, SAN, NFS). MinIO strongly recommends flash storage (NVMe, SSD) for primary or “hot” data.

- `Use XFS-Formatting for Drives`: MinIO strongly recommends provisioning XFS formatted drives for storage. MinIO uses XFS as part of internal testing and validation suites, providing additional confidence in performance and behavior at all scales.

- `Persist Drive Mounting and Mapping Across Reboots`: Use /etc/fstab to ensure consistent drive-to-mount mapping across node reboots.


### Create a directory: 

MinIO needs a directory to store its data. Create a directory for this purpose:

```
mkdir -p /minio/data
mkdir -p /opt/minio/bin
```


### Download the MinIO Binary:
Use `wget` to download the MinIO binary:

```
cd /opt/minio/bin
wget https://dl.minio.io/server/minio/release/linux-amd64/minio

chmod +x minio
mv minio /usr/local/bin
```


```
### version check:

minio -v

minio version RELEASE.2024-05-10T01-41-38Z (commit-id=b5984027386ec1e55c504d27f42ef40a189cdb55)
Runtime: go1.22.3 linux/amd64
License: GNU AGPLv3 - https://www.gnu.org/licenses/agpl-3.0.html
Copyright: 2015-2024 MinIO, Inc.
```




### Start MinIO Server:

- `--address` : to set the API port.
- `--console-address` : to set the Console port.
- `minio server` : command starts the MinIO server. MinIO Server started wwith default RootUser: minioadmin and RootPass: minioadmin; like:  
  `minio server /minio/data --console-address :9001`

- The path argument `/minio/data` identifies the data directory in which the server operates.

- Create a bash file to hold the environment variables, which includes the MinIO root user and root password. 

Now, open a new bash file (`minio.sh`) in directory `/opt/minio/bin/` with your favorite text editor like: `vim /opt/minio/bin/minio.sh`

```
#!/bin/bash

export MINIO_ROOT_USER=minio
export MINIO_ROOT_PASSWORD=minio@dmin

#/opt/minio/bin/minio server /minio/data --address :9000
/opt/minio/bin/minio server /minio/data --console-address :9001

### Or:###

#MINIO_ROOT_USER=minio MINIO_ROOT_PASSWORD=minio@dmin /opt/minio/bin/minio server /minio/data --console-address :9001
```


```
chmod +x /opt/minio/bin/*

cd /opt/minio/bin
./minio.sh
```



**The minio server process prints its output to the system console, similar to the following**:

```
MinIO Object Storage Server
Copyright: 2015-2024 MinIO, Inc.
License: GNU AGPLv3 - https://www.gnu.org/licenses/agpl-3.0.html
Version: RELEASE.2024-05-10T01-41-38Z (go1.22.3 linux/amd64)

API: http://192.168.10.190:9000  http://192.168.122.1:9000  http://127.0.0.1:9000
   RootUser: minio
   RootPass: minio@dmin

WebUI: http://192.168.10.190:9001 http://192.168.122.1:9001 http://127.0.0.1:9001
   RootUser: minio
   RootPass: minio@dmin

CLI: https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart
   $ mc alias set 'myminio' 'http://192.168.10.190:9000' 'minio' 'minio@dmin'

Docs: https://min.io/docs/minio/linux/index.html
Status:         1 Online, 0 Offline.

STARTUP WARNINGS:
- The standard parity is set to 0. This can lead to data loss.

```



### Accessing MinIO:

MinIO by default runs on port 9000. You can access the MinIO web interface by navigating to http://your-server-ip:9000 or Console: http://your-server-ip:9001 in your web browser.  
While the port 9000 is used for connecting to the API, MinIO automatically redirects browser access to the MinIO Console.



---
---



### Install the MinIO Client (Optional):

The MinIO Client allows you to work with your MinIO server from the commandline. MinIO provides a client called mc (MinIO Client) which you can use to manage your MinIO server. To install and configure the MinIO Client:


```
cd /opt/minio/bin
wget https://dl.min.io/client/mc/release/linux-amd64/mc

chmod +x mc
mv mc /usr/local/bin
```


```
mc -help
```


```
mc -v

mc version RELEASE.2024-05-09T17-04-24Z (commit-id=fdb36acbb1d793b6cca622a55e6292f0d52309f0)
Runtime: go1.22.3 linux/amd64
Copyright (c) 2015-2024 MinIO, Inc.
License GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
```


The `mc update` command automatically updates the mc binary to the latest stable version.

```
mc update
```


### Configure the MinIO client with your MinIO server:

Use `mc alias set` to create a new alias associated to your local deployment. You can run `mc` commands against this alias name is `local`:

```
mc alias set minio_name http://<your-server-ip>:9000 YOUR-ACCESS-KEY YOUR-SECRET-KEY

mc alias set local http://192.168.10.190:9000 minio minio@dmin

    Added `local` successfully.
```


```
mc alias list
```


```
mc admin info local

●  0.0.0.0:9000
   Uptime: 1 minute
   Version: 2024-05-10T01:41:38Z
   Network: 1/1 OK
   Drives: 1/1 OK
   Pool: 1

Pools:
   1st, Erasure sets: 1, Drives per erasure set: 1

0 B Used, 1 Bucket, 0 Objects
1 drive online, 0 drives offline, EC:0
```


```
mc ls local

    [2024-05-27 16:46:47 +06]     0B test2/


mc ls local/test2

    [2024-05-27 16:46:47 +06] 1.4KiB STANDARD main.py
```


### Create a Bucket:

```
mc mb local/newbucket

    Bucket created successfully `local/newbucket`.
```


### Copy a file from the local filesystem to a MinIO bucket::

The mc cp command is a versatile tool for copying files and objects between your local filesystem and MinIO, as well as between different MinIO servers or S3-compatible storage systems.


```
### Syntax:
mc cp /path/to/local/file local/bucketname


mc cp example.txt local/newbucket
mc cp /home/istl/foo local/newbucket

    /home/istl/foo:     33 B / 33 B ┃▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 3.34 KiB/s 0s
```


### Copy a file from a MinIO bucket to the local filesystem:

```
### Syntax:
mc cp local/bucketname/filename /path/to/local/destination


mc cp local/newbucket/foo /home/istl/foo2

    .../0.0.0.0:9000/newbucket/foo: 33 B / 33 B ┃▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 2.97 KiB/s 0s
```


### Copy a file between two MinIO buckets:

```
### Syntax:
mc cp myminio/sourcebucket/filename myminio/targetbucket

mc cp local/newbucket/foo local/test2

    ....0.0:9000/newbucket/foo: 33 B / 33 B ┃▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 4.35 KiB/s 0s
```


### Copy all objects from one bucket to another:

- `--recursive` : Copy all objects recursively from the source to the target.
- `--preserve` : Preserve filesystem attributes (e.g., modification time, access time).
- `--attr` : Specify custom metadata to set for the target objects.

```
### Syntax:
mc cp --recursive myminio/sourcebucket myminio/targetbucket

mc cp --recursive local/newbucket local/test3

    ....0.0:9000/newbucket/foo: 33 B / 33 B ┃▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 5.54 KiB/s 0s
```


### Delete a single object from a bucket:

```
### Syntax:
mc rm myminio/bucketname/objectname

mc rm local/test2/foo

    Removed `local/test2/foo`.
```


### Delete all objects in a bucket recursively:

- `--recursive` : Recursively delete objects.
- `--force` : Bypass the prompt for confirmation.
- `--incomplete` : Remove incomplete uploads.
- `--dangerous` : Allow deletion of non-empty buckets (use with caution).


```
### Syntax:
mc rm --recursive --force myminio/bucketname

mc rm --recursive --force local/test3

    Removed `local/test3/newbucket/foo`.
```


### Delete all incomplete uploads in a bucket:

```
mc rm --incomplete local/test3
```


### Remove an empty bucket:
To delete a bucket using the MinIO Client (mc), you can use the mc rb (remove bucket) command. This command removes an empty bucket. If you want to delete a bucket along with all its contents, you need to use the --force flag with the mc rb command. 

```
### Syntax:
mc rb myminio/mybucket

mc rb local/test3

    Removed `local/test3` successfully.
```


### Remove a bucket and all its contents:

- `--force` : Force remove the bucket and all its contents without prompting for confirmation.
- `--dangerous` : Use with --force to confirm the deletion of the bucket and its contents.

```
mc rb --force --dangerous local/test2

    Removed `local/test2` successfully.
```



> [!IMPORTANT]  
> `RELEASE.2022-10-29T06-21-33Z` fully removes the deprecated Gateway/Filesystem backends. MinIO returns an error if it starts up and detects existing Filesystem backend files.  
To migrate from an FS-backend deployment, use mc mirror or mc cp to copy your data over to a new MinIO Single-Node Single-Drive (SNSD) deployment. You should also recreate any necessary users, groups, policies, and bucket configurations on the SNSD deployment.  


> [!CAUTION]  
> ERROR Unable to use the drive /opt/minio/data: Drive /opt/minio/data: found backend type fs, expected xl or xl-single - to migrate to a supported backend visit https://min.io/docs/minio/linux/operations/install-deploy-manage/migrate-fs-gateway.html: Invalid arguments specified 



### Links:
- [Install MinIO](https://min.io/docs/minio/linux/index.html)
- [MinIO Client](https://min.io/docs/minio/linux/reference/minio-mc.html)
- [User Management CLI](https://min.io/docs/minio/linux/administration/identity-access-management/minio-user-management.html)
- [Migrate from Gateway or Filesystem Mode](https://min.io/docs/minio/linux/operations/install-deploy-manage/migrate-fs-gateway.html)
- [MinIO: Single-Node Single-Drive](https://min.io/docs/minio/container/operations/install-deploy-manage/deploy-minio-single-node-single-drive.html)
- [MinIO Github](https://github.com/minio/minio/)
