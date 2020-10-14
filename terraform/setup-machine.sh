#!/bin/bash

EFS_ID=$1

sudo apt-get update

wget -c https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
echo "export GOPATH=\$HOME/go" >> ~/.profile
echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.profile
source ~/.profile
mkdir -p $GOPATH
go get github.com/prasmussen/gdrive

mkdir ~/.gdrive
mv credentials.json ~/.gdrive/

git clone https://github.com/aws/efs-utils
cd efs-utils
sudo apt-get -y install binutils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
cd -

mkdir -p $HOME/scratch
sudo mount -t efs $EFS_ID:/ $HOME/scratch