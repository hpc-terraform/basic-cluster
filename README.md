# basic-cluster
Build of a basic project setup for a dynamic cluster on GPC

# Getting starting

## Begin by getting authorization for terraform and hpc-toolkit

Go to https://cloud.google.com/hpc-toolkit/docs/quickstarts/slurm-cluster

Run 2-7

Go to https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com/metrics

and enable

## Request a GCP workgroup through Stanford
  
  - Give that work group the following gcp permssions (needs to be updated)
    - iap tunnel user
    - service account user
  - Add all users for the system to the workgroup


## Create your terraform node

Start your cloudshell

- Clone this repository

- Create a terraform.tfvars file in setup

  - Set at minimum the 
    - project-id
      - Project name
    - bucket-ro
      - Unique name for the bucket for read-only
    - bucket-rw
      - Unique name for bucket for read/write data
    - gcp-workgroup
      - Stanford GCP workgroup from previous step
- cd setup &&

    terrafrom init

    terraform plan 
    
    terraform apply --auto-approve
    
 In a couple minutes you should then have a node with all the software and permissions you need
 
# Create your cluster 

- Clone this repository to your terraform node

- Start from one of the examples in `examples' directory to create your desired cluster
   - Make sure to change your project_id (at a minimum)
- Edit the Makefile so that the yaml variable points to your yaml file
- make -n prep
  - Copy the produced text and run in a terminal
  - Install the required python packages in a virtual environment
- . ~/hpc-toolkit/bin/activate
  - Activate the environment
- . ~/.bashrc
  - Add ghpc to your environment
- make build_disk
  - Build the disk image
- make build_cluster
  - Build the cluster
- Optionally build a machine where people can open a display 
  - make build_desktop
