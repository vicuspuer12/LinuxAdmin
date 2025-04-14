#Check your Ubuntu version
lsb_release -a
 
#Installing Unifi Repo
sudo apt-get update && sudo apt-get install ca-certificates apt-transport-https
echo 'deb [ arch=amd64,arm64 ] https://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list
sudo wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg
 
#Alternativly download the package directly
 
https://dl.ui.com/unifi/8.0.28/unifi_sysvinit_all.deb
 
#Fixing the dependencies
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb -O libssl1.1.deb
sudo dpkg -i libssl1.1.deb
 
curl https://pgp.mongodb.com/server-4.4.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/mongodb-org-server-4.4-archive-keyring.gpg >/dev/null
echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-org-server-4.4-archive-keyring.gpg] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null
 
sudo apt update && sudo apt install -y mongodb-org-server
sudo systemctl enable mongod && sudo systemctl start mongod
 
#Installing Unifi
sudo apt-get update && sudo apt-get install unifi -y
sudo systemctl enable unifi && sudo systemctl restart unifi
