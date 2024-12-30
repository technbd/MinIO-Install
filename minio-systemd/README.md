
## Minio as a Systemd Service:

Systemd is a system and service manager for Linux. We’ll create a `systemd` service file for Minio, which will allow us to start, stop, and manage Minio like any other service.



### Create a Minio Configuration File:
Minio requires a configuration file to define key environment variables, such as the location of the data directory or partition. Add the following lines:

```
vim run-minio.conf


# MinIO storage directory
#MINIO_VOLUMES="/tmp/minio-data"

MINIO_DATA="/tmp/minio-data"

# MinIO console management port
MINIO_OPTS="--console-address :9001"

# MinIO root user credentials (use strong values in production)
MINIO_ROOT_USER="rcms"
MINIO_ROOT_PASSWORD="rcms1234"

```



### Create the service file:


#### When `WorkingDirectory` is Needed: 
- **Custom Executable Paths or Relative Paths**: If your MinIO binary, data, or configuration files rely on relative paths, the `WorkingDirectory` ensures the correct directory is set.

    - If your `run-minio.conf` or other files are located in `/home/rcms/minio`, this ensures the service can find them without requiring absolute paths.


```
[Service]

WorkingDirectory=/home/rcms/minio
ExecStart=/home/rcms/minio/minio server $MINIO_OPTS $MINIO_DATA
```


#### When `WorkingDirectory` is Not Needed: 

- **Absolute Paths**: If you provide absolute paths for:
    - The MinIO binary (e.g., `/home/rcms/minio/minio`).
    - The configuration file (e.g., `/home/rcms/minio/run-minio.conf`).
    - Data directories (e.g., `/tmp/minio-data`). **Then the `WorkingDirectory` is not required.**



Ensure all paths in the service file and related configuration (like `run-minio.conf`) are absolute paths. Including `WorkingDirectory` is optional but recommended for clarity and simplicity.

```
[Service]

EnvironmentFile=/home/rcms/minio/run-minio.conf
ExecStart=/home/rcms/minio/minio server /tmp/minio-data
```



_Minio Service File:_

```
vim /etc/systemd/system/minio.service


[Unit]
Description=Minio
Documentation=https://docs.minio.io
Wants=network-online.target
After=network-online.target

# Ensure MinIO binary is executable
AssertFileIsExecutable=/home/rcms/minio/minio

[Service]
WorkingDirectory=/home/rcms/minio

User=rcms
Group=rcms

# Load environment variables, if the file exists
EnvironmentFile=-/home/rcms/minio/run-minio.conf


#ExecStartPre=/bin/bash -c "[ -n \"${MINIO_VOLUMES}\" ] || echo \"Variable MINIO_VOLUMES not set in /home/rcms/minio/run-minio.conf\""
#ExecStartPre=/bin/bash -c "[ -n \"${MINIO_DATA}\" ] || echo \"Variable MINIO_DATA not set in /home/rcms/minio/run-minio.conf\""


# Main command to start MinIO, with configured options
ExecStart=/home/rcms/minio/minio server $MINIO_OPTS $MINIO_DATA


# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity

# SIGTERM signal is used to stop Minio gracefully
KillSignal=SIGTERM
SendSIGKILL=no

# Define valid exit codes
SuccessExitStatus=0

[Install]
WantedBy=multi-user.target

```



_To enable and start the service:_

```
systemctl daemon-reload

systemctl start minio
systemctl enable minio

systemctl restart minio
systemctl status minio
```

