#!/bin/bash


echo ""
echo "Starting Install - Java 8, jq, awscli, unzip"
echo ""

sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt install -y openjdk-8-jdk jq awscli unzip

echo ""
echo "Install Docker from their repository"
echo ""

sudo apt install apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo chmod a+s "command -v docker"
sudo usermod -aG docker "$(whoami)"
