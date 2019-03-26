			 
#!/bin/bash


#enter the bucket name for the creation of kops

# it should be in the format <test-cluster.test.uniconnect.io>

echo "###################################### taking the bucket name##########################"

bucketname=$1

sudo apt-get update && sudo apt-get install -y apt-transport-https

echo "##########################installing aws cli#########################"

sudo apt-get install awscli -y
 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

result=`echo "$?"`

 echo "$result"

echo "checking the condition"
  if [ "$?" -eq 1 ] ;
  then
      exit 1
  else
echo "the condition is true"

echo "#############################updating the packages ###############"
sudo apt-get update
 
sudo apt-get install -y kubectl
echo "#########################Downloading the KOPS#########################"

wget https://github.com/kubernetes/kops/releases/download/1.10.0/kops-linux-amd64

chmod +x kops-linux-amd64

sudo mv kops-linux-amd64 /usr/local/bin/kops

kops create secret --name $1 sshpublickey admin -i ~/.ssh/id_rsa.pub

aws s3 mb s3://$1 --region us-east-2

#KOPS_STATE_STORE=`echo s3://$bucketname

export KOPS_STATE_STORE=s3://$1

kops create cluster --name=$1 --cloud=aws --zones=us-east-2a,us-east-2b --master-size=t2.large --node-count=2 --node-size=t2.large  --master-zones=us-east-2a,us-east-2b,us-east-2c --state=s3://$1 --topology=private --networking=flannel --bastion
  fi
