# basic-cluster
Build of a basic project setup for a dynamic cluster on GPC

# Getting starting

## Begin by getting authorization for terraform and hpc-toolkit

Go to https://cloud.google.com/hpc-toolkit/docs/quickstarts/slurm-cluster

Run 2-7

Go to https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com/metrics

and enable

## Create your terraform node

Start your cloudshell

- Clone this repository

- Create a terraform.tfvars file in setup

  - Set at minimum the project-id

- cd setup &&
    terrafrom init
    terraform plan 
    terraform apply --auto-approve
