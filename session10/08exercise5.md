---
title: Exercise 5 - Distributed computing
---

## Exercise 5: Distributed computing

### Again, with Hadoop

In the previous exercise, we demonstrated the Map/Reduce functions on our local computer.

In this exercise we will spin up multiple cloud instances, making use of Hadoop to carry out a Map Reduce operation.

We could set up multiple instances in the cloud (for example with EC2), then configure Hadoop to run across the instances. This is not trivial and takes time. 

### Hadoop in the cloud

Fortunately, several cloud providers offer configurable Hadoop services. One such service is Amazon Elastic MapReduce.

Elastic MapReduce (EMR) provides a framework for:

- uploading data and code to the Simple Storage Service (S3)
- analysing with a multi-instance cluster on the Elastic Compute Cloud (EC2)

### Create an S3 bucket

Create an S3 bucket to hold the input (the book; our map/reduce functions) and log files:

1. Open the Amazon Web Services Console: http://aws.amazon.com/
2. Select "Create Bucket" and enter a globally unique name
3. Ensure the S3 Bucket shares the same region as other instances in your cluster
4. Create subfolders for the input and logs (e.g. ```s3://my-bucket-ucl123/input```)

<!-- 
May need to do more from here: http://docs.aws.amazon.com/ElasticMapReduce/latest/DeveloperGuide/emr-cli-install.html
-->

### Copy data and code to S3

``` bash
# copy input code and data to the input folder
$ aws s3 cp dorian.txt s3://my-bucket-ucl123/input/
$ aws s3 cp mapper.py s3://my-bucket-ucl123/input/
$ aws s3 cp reducer.py s3://my-bucket-ucl123/input/
```

### Launch the compute cluster

Create a compute cluster with one master instance and two core instances:

``` bash
# Start a EMR cluster
# <ami-version>: version of the machine image to use
# <instance-type>:  number and type of Amazon EC2 instances
# <key_name>: "mykeypair"
$ aws emr create-cluster --ami-version 3.1.0 \
    --ec2-attributes KeyName=<key_name> \
    --instance-groups InstanceGroupType=MASTER,InstanceCount=1,InstanceType=m3.xlarge \
    InstanceGroupType=CORE,InstanceCount=2,InstanceType=m3.xlarge

"ClusterId": "j-3HGKJHEND0DX8"
```

### Identify the cluster

Get the cluster-id:

``` bash
# Get the cluster-id
$ aws emr list-clusters
    ...
    "Id": "j-3HGKJHEND0DX8", 
    "Name": "Development Cluster"
```

Once the cluster is up and running, get the public DNS name:

``` bash
# Get the DNS
$ aws emr describe-cluster --cluster-id j-3HGKJHEND0DX8 \
    | grep MasterPublicDnsName
    ...
    "MasterPublicDnsName": "ec2-52-16-235-144.eu-west-1.compute.amazonaws.com"
```

### Connect to the cluster

SSH into the cluster using the username 'hadoop':

``` bash
# SSH into the master node
# <key_file>: ~/.ssh/ec2
# <MasterPublicDnsName>: ec2-52-16-235-144.eu-west-1.compute.amazonaws.com
$ ssh hadoop@<MasterPublicDnsName> -i <key_file> 
```

``` bash
# Connected 
       __|  __|_  )
       _| \(     /   Amazon Linux AMI
      ___|\\___|___|

[hadoop@ip-x ~]$ 
```

### Run the analysis

``` bash
[hadoop@ip-x ~]$ hadoop \
       jar ~/contrib/streaming/hadoop-streaming.jar \
       -mapper 'python s3://my-bucket-ucl123/input/mapper.py' \
       -reducer 'python s3://my-bucket-ucl123/input/reducer.py' \
       -input s3://my-bucket-ucl123/input/dorian.txt \
       -output s3://my-bucket-ucl123/output/
```

### Terminate the cluster

Once the analysis is complete, terminate the cluster:

``` bash
$ aws emr terminate-clusters --cluster-id j-3HGKJHEND0DX8
```

### View the results

Results have been saved to the output folder:

``` bash
# List files in the output folder
$ aws s3 ls s3://my-bucket-ucl123/output/
```

Download the output:

``` bash
# Copy the output file to our local folder
$ aws s3 cp s3://my-bucket-ucl123/output/output.txt ./

# View the file
$ head output.txt
```

