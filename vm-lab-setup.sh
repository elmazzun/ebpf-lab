# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04
readonly GO_VERSION="1.16.7"

echo ">>> Update your existing list of packages"
sudo apt update

echo ">>> Install a few prerequisite packages which let apt use packages over HTTPS"
sudo apt install -y apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo ">>> Add the GPG key for the official Docker repository to your system"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor \
    -o /usr/share/keyrings/docker-archive-keyring.gpg

echo ">>> Add the Docker repository to APT sources"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ">>> Update your existing list of packages again for the addition to be recognized"
sudo apt update

echo ">>> Make sure you are about to install from the Docker repo instead of the default Ubuntu repo"
apt-cache policy docker-ce

sudo apt install -y docker-ce

sleep 3

sudo systemctl status docker


echo ">>> Avoid typing sudo whenever you run the docker command by adding your username to the docker group"
sudo usermod -aG docker vagrant
echo "vagrant" | su - vagrant

sudo docker run hello-world

# https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04
echo ">>> Installing golang v$GO_VERSION"
curl -OL https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz  --output-dir /tmp
sudo tar -C /usr/local -xf /tmp/go$GO_VERSION.linux-amd64.tar.gz
rm -rf /tmp/go$GO_VERSION.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> /home/vagrant/.profile
source ~/.profile
go version
