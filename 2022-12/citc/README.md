# Virtual cluster in AWS for EESSI hackathon Dec'22

Created with [Cluster-in-the-Cloud (CitC)](https://cluster-in-the-cloud.readthedocs.io).

Cluster ID: ``fair-mastodon``
IP address: ``34.245.120.28``

### Access

Ask Kenneth (@boegel) to create you an account using your GitHub handle.

Then log in with SSH:

```
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519_github_com boegel@34.245.120.28
```

Or add something like this to your ``~/.ssh/config``:

```
Host citc-eessi-hackathon
  User boegel
  HostName 34.245.120.28
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519_github_com
```

(change `boegel` and the `IdentityFile` path)

### Login node

**The login node has limited resources, and the EESSI pilot repository is not mounted there!**
Please start an interactive session on a workernode, or submit job scripts.

### Node types

https://aws.amazon.com/ec2/instance-types

(see also output of ``list_nodes`` command)

* ``x86_64``:
  * ``c4.2xlarge``: Intel Xeon - Haswell (``haswell``)
  * ``c5.2xlarge``: Intel Xeon - Skylake-X (``skylake_avx512``)
  * ``c5d.2xlarge``: Intel Xeon - Skylake-X (``skylake_avx512``) - SSD
  * ``c5a.2xlarge``: AMD EPYC - Rome (``zen2``)
  * ``c6i.2xlarge``: Intel Xeon - Cascade Lake (``cascadelake``)
* ``aarch64``
  * ``c6g.2xlarge``: Arm Graviton 2 (``graviton2``)
  * ``c6gd.2xlarge``: Arm Graviton 2 (``graviton2``) - SSD

All ``c*.2xlarge`` node types have 8 cores and ~16GB of memory.

All compute nodes have a local disk of ~200GB + (elastic) shared filesystem (NFS) in ``/mnt/shared``:

```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        7.3G     0  7.3G   0% /dev
tmpfs           7.3G     0  7.3G   0% /dev/shm
tmpfs           7.3G   17M  7.3G   1% /run
tmpfs           7.3G     0  7.3G   0% /sys/fs/cgroup
/dev/xvda1      200G  3.9G  197G   2% /
fileserver:/    8.0E     0  8.0E   0% /mnt/shared
```

No fast interconnect between nodes (no EFA).

### Slurm

Workernodes are spun up automatically when jobs are submitted (and are powered down when there are no jobs).

To submit a job to a specific node type, use ``-C shape=...``

```
sbatch -N 1 -n 8 -C shape=c4.2xlarge script.sh
```

To start an interactive session on a specific node type:

```
$ srun -N1 -n8 -C shape=c6g.2xlarge --time=3:0:0 --pty /bin/bash
[boegel@fair-mastodon-c6g-2xlarge-0001 ~]$ archspec cpu
graviton2
```

### Software

* OS: Rocky Linux 8.6
* tools:
  * ``archspec``
  * CernVM-FS
  * Singularity

### Accessing EESSI

EESSI is readily available on the compute nodes:

```shell
[boegel@fair-mastodon-c4-2xlarge-0001 ~]$ source /cvmfs/pilot.eessi-hpc.org/2021.12/init/bash
Found EESSI pilot repo @ /cvmfs/pilot.eessi-hpc.org/2021.12!
Using x86_64/intel/haswell as software subdirectory.
Using /cvmfs/pilot.eessi-hpc.org/2021.12/software/linux/x86_64/intel/haswell/modules/all as the directory to be added to MODULEPATH.
Found Lmod configuration file at /cvmfs/pilot.eessi-hpc.org/2021.12/software/linux/x86_64/intel/haswell/.lmod/lmodrc.lua
Initializing Lmod...
Prepending /cvmfs/pilot.eessi-hpc.org/2021.12/software/linux/x86_64/intel/haswell/modules/all to $MODULEPATH...
Environment set up to use EESSI pilot software stack, have fun!
[EESSI pilot 2021.12] $
```
