# k8s-terraform

![Terraform-K8s-Mongo](Terraform-K8s-Mongo.png)
## Steps
* Change to the terraform directory, `cd terraform`

* Initialize terraform on the directory to download required providers

`terraform init`

* Validate the terraform file using :

` terraform plan `

* Apply the terraform configuraton file 

`terraform apply -var-file=example.tfvars --auto-approve`

* Copy the output of the terraform configuration to the  `~/.kube/config`

* Installing aws-iam-authenticator
This enables using AWS IAM credentials to authenticate to a Kubernetes cluster 

```
curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
```
## Accessing Mongodb Server via Bastion host
* ssh into bastion host, Make sure you include -A
```ssh _A -i path/to/keypair ubuntu@Pub-IP```
* ssh into mongo server
```ssh bitnami@Priv-IP```
* Access root username and pass
```ls bitnami_credentials```
* Login to mongo shell by running "mongo"
* Authenticate and create a new user, update values as required
```
use admin
db.auth("root","mongo-root-password")
db.createUser(
  {
    user: "username",
    pwd: "password",
    roles: [ { role: "readWrite", db: "dbAdmin" } ]
  }
)
```
* Grant the required roles
```
db.grantRolesToUser("username", [{ role: "readWrite", db: "go-mongodb" }])
```
* Update MONGODB_URL (You can refer to the tasky folder)
```
MONGODB_URL: mongodb://username:password@hostname:port
```
* Update the manifest files with the appropriate values after encryting with base64

* Deploy the manifest for the secret and pods deployment 

```
kubectl apply -f manifests/secret1.yaml
kubectl apply -f manifests/secret2.yaml
kubectl apply -f manifests/deployment.yaml
```

* Validate the deployment using `kubectl get pods`

* Testing the deployment using the port forward e.g

`kubectl port-forward <pod> 8080:8080`

* Deploy the service loadbalancer on the cluster `kubectl apply -f manifest/loadbalancer.yaml`

![tasky](tasky.png)

# mongo-to-s3

The `mongo-to-s3` package provides a convenient way to backup MongoDB databases and upload the backups to Amazon S3 for safekeeping. This utility allows you to automate the backup process and ensure the security and availability of your MongoDB data.

## Features

-   Automatically creates backups of MongoDB databases.
-   Compresses backups and stores them securely in Amazon S3.
-   Generates customizable backup scripts based on user inputs.
-   Supports scheduling backup jobs using cron.
-   Provides logging functionality to track backup activity and errors.

## Installation

1. Ensure you have Python 3 installed on your system.

2. Install the package using pip:

    ```shell
    pip install mongo-to-s3
    ```

## Usage

1. Open a terminal or command prompt.

2. Run the `mongo-to-s3` command with the required options,

    ```shell
    mongo-to-s3 -dHost <db_host> -dPort <db_port> -dName <db_name> -sName <s3_bucket_name> -sFolder <s3_folder_name> -sRegion <s3_region>
    ```

    Replace the placeholders (`<db_host>`, `<db_port>`, `<db_name>`, `<s3_bucket_name>`, `<s3_folder_name>`, `<s3_region>`) with the appropriate values for your setup.

3. You will be prompted to enter the database username, database password, S3 access key, and S3 secret key.

4. The backup script will be generated and scheduled to run using cronjobs. By default, it will run every 12 hours. You can customize the cron schedule by adding the `-cSchedule` option followed by the desired schedule.

    ```shell
    mongo-to-s3 -dHost <db_host> -dPort <db_port> -dName <db_name> -sName <s3_bucket_name> -sFolder <s3_folder_name> -sRegion <s3_region> -cSchedule "0 0 * * *"
    ```

    This example schedules the backup to run daily at midnight.

5. The generated backup script will be placed in the mongo-to-s3-scripts directory in the user's home directory.

    You can generate backup script for all of your MongoDB databases this way.

### Logs

The `mongo-to-s3` utility creates log files for each backup operation. The log files contain information about the backup process and any errors that may have occurred. By default, the log files are stored in the `mongo-to-s3-logs` directory in the user's home directory.

You can check the logs to monitor the backup activity and troubleshoot any issues that may arise. The log file names follow the format: `<db_name>_log_<timestamp>.txt`.

To view the logs, navigate to the `mongo-to-s3-logs` directory:

```shell
cd ~/mongo-to-s3-logs
```

## Clean Up Resources

`terraform destroy -var-file=example.tfvars --auto-approve`













