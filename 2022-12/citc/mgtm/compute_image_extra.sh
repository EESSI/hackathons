#! /bin/bash
# Add any commands you wish to run in the compute image to this file
# and rerun `run-packer`
# If you need root permissions for any commands, use sudo

# no longer needed, already done in /etc/citc/packer/prepare_ansible.sh
# see also https://github.com/clusterinthecloud/ansible/issues/121
#tmpdir=$(mktemp -d)
#cd $tmpdir
#curl -OL https://raw.githubusercontent.com/rocky-linux/rocky-tools/68c77ad/migrate2rocky/migrate2rocky.sh
#chmod u+x migrate2rocky.sh
#sudo ./migrate2rocky.sh -r
#cd -

sudo dnf config-manager --set-enabled powertools
sudo dnf install -y epel-release vim python36 python3-pip Lmod which git gcc-c++ make patch file bzip2 unzip tar xz openssl openssl-devel rdma-core-devel glibc-static
rpm -qa | grep environment-modules; if [[ $? -eq 0 ]]; then sudo dnf remove environment-modules; fi
sudo dnf install -y apptainer
sudo pip3 install archspec

# install CernVM-FS (see https://cernvm.cern.ch/fs)
# EL8 packages are available for both x86_64 and aarch64
sudo dnf install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
sudo dnf install -y cvmfs

# install latest CernVM-FS configuration for EESSI (see https://github.com/EESSI/filesystem-layer#clients)
sudo dnf install -y https://github.com/EESSI/filesystem-layer/releases/download/latest/cvmfs-config-eessi-latest.noarch.rpm

# configure CernVM-FS (no proxy, 100GB quota for CernVM-FS cache)
sudo bash -c "echo 'CVMFS_HTTP_PROXY=DIRECT' > /etc/cvmfs/default.local"
sudo bash -c "echo 'CVMFS_QUOTA_LIMIT=100000' >> /etc/cvmfs/default.local"
sudo cvmfs_config setup

# allow user with id 10006 to use singularity --fakeroot
# see https://sylabs.io/guides/3.5/user-guide/fakeroot.html
echo '10006:4294836224:65536' | sudo tee -a /etc/subuid
echo '10006:4294836224:65536' | sudo tee -a /etc/subgid

# update to latest Slurm (to match Slurm controller on head node)
# see also https://github.com/clusterinthecloud/ansible/issues/122
sudo dnf update -y slurm


#! /bin/bash
# Add any commands you wish to run in the compute image to this file
# and rerun `run-packer`
# If you need root permissions for any commands, use sudo
