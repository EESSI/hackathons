# Virtual clusters in AWS and OpenStack for EESSI hackathon Dec'21

Created with [Magic Castle](https://github.com/ComputeCanada/magic_castle).

Fast interconnect cluster is on AWS (using EFA, AVX512 arch):
* Sign up:  https://mokey.eessi.learnhpc.eu/auth/signup  
* Manage ssh keys:  https://mokey.eessi.learnhpc.eu/sshpubkey
* Address (ssh or https):  [``eessi.learnhpc.eu``](eessi.learnhpc.eu)

GPU enabled cluster (V100 GPU, AMD EPYC):

* Sign up:  https://mokey.eessi-gpu.learnhpc.eu/auth/signup  
* Manage ssh keys:  https://mokey.eessi-gpu.learnhpc.eu/sshpubkey
* Address (ssh or https):  [``eessi-gpu.learnhpc.eu``](eessi-gpu.learnhpc.eu)

### Access

Notify Alan (@ocaisa) in Slack to enable your account once you have completed the signup.

You can log in using the username/password that you set during signup either via ssh or
via JupyterHub (https link). For ssh login you can also use the link above to add an ssh
key.

### Node types

* `eessi` (AWS): ``x86_64``:
  * ``c5n.9xlarge``: Intel Xeon - Skylake-X (``skylake_avx512``)
* `eessi-gpu` (JUSUF, OpenStack): ``x86_64``:
  * AMD EPYC, V100 GPU


The local disks are 10G with shared filesystems (NFS) of 50G on `/home`, `/project` and `/scratch`.
```
[ocaisa@node1 ~]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
/dev/nvme0n1p1        10G  5.4G  4.7G  54% /
tmpfs                 47G     0   47G   0% /sys/fs/cgroup
devtmpfs              47G     0   47G   0% /dev
tmpfs                 47G     0   47G   0% /dev/shm
tmpfs                 47G   17M   47G   1% /run
cvmfs2               4.0G  102M  4.0G   3% /cvmfs/cvmfs-config.cern.ch
cvmfs2               4.0G  102M  4.0G   3% /cvmfs/pilot.eessi-hpc.org
10.0.0.168:/home      10G  104M  9.9G   2% /home
10.0.0.168:/project   50G  390M   50G   1% /project
10.0.0.168:/scratch   50G  390M   50G   1% /scratch```


### Slurm

Nothing special to say here, normal Slurm options apply. Only thing to note is that the default memory
allocation is quite low so probably a good idea to include an explicit memory request, e.g.:
```
#SBATCH --mem=15G
```

### Software

* OS: Rocky Linux 8
* tools:
  * CernVM-FS
  * Singularity

### Accessing EESSI

EESSI is readily available on the compute nodes and loaded by default.
