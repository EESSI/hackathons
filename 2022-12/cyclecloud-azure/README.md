# Virtual cluster in Azure for EESSI hackathon Dec'22

Created with [Azure CycleCloud](https://learn.microsoft.com/en-us/azure/cyclecloud/overview).

Cluster ID: ``eessi-slurm``
IP address: ``13.80.250.88``

### Access

Ask Kenneth (@boegel) to create you an account.

Then log in with SSH:

```
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519_eessi_cyclecloud boegel@13.80.250.88
```

Or add something like this to your ``~/.ssh/config``:

```
Host cyclecloud-eessi
  User boegel
  HostName 13.80.250.88
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519_eessi_cyclecloud
```

(change `boegel` and the `IdentityFile` path)

### Login node

**The login node has limited resources, and the EESSI pilot repository is not mounted there!**
Please start an interactive session on a workernode, or submit job scripts.

### Node types

* ``hpc`` partition
  * [Standard_HB120rs_v3](https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/hpc/hbv3-series-overview)
* ``htc`` partition
  * [Standard_D4s_v3](https://learn.microsoft.com/en-us/azure/virtual-machines/dv3-dsv3-series#dsv3-series)

All compute nodes have a local disk of ~100GB + shared filesystem (NFS) in ``/shared``:

```
$ df -h
Filesystem         Size  Used Avail Use% Mounted on
devtmpfs           7.8G     0  7.8G   0% /dev
tmpfs              7.8G     0  7.8G   0% /dev/shm
tmpfs              7.8G  9.1M  7.8G   1% /run
tmpfs              7.8G     0  7.8G   0% /sys/fs/cgroup
/dev/sda2          100G  4.3G   95G   5% /
/dev/sda1          494M   76M  419M  16% /boot
/dev/sda15         495M   12M  484M   3% /boot/efi
/dev/sdb1           32G   49M   30G   1% /mnt/resource
10.0.12.4:/sched   100G   33M  100G   1% /sched
10.0.12.4:/shared  1.0T   51M  1.0T   1% /shared
tmpfs              1.6G     0  1.6G   0% /run/user/0
```

### Slurm

Workernodes are spun up automatically when jobs are submitted (and are powered down when there are no jobs).

To submit a job to a specific node type, use ``--partition=...``

```
sbatch -N 1 -n 4 --partition=htc script.sh
```

To start an interactive session on a specific node type:

```
$ srun -N1 -n4 --partition=htc --time=3:0:0 --pty /bin/bash
```

### Software

* OS: CentOS 7.9
* tools:
  * ``archspec``
  * CernVM-FS
  * Singularity

### Accessing EESSI

EESSI is readily available on the compute nodes:

```shell
[boegel@eessi-slurm-htc-1 scripts]$ source /cvmfs/pilot.eessi-hpc.org/latest/init/bash
Found EESSI pilot repo @ /cvmfs/pilot.eessi-hpc.org/versions/2021.12!
archspec says x86_64/intel/haswell
Using x86_64/intel/haswell as software subdirectory.
Using /cvmfs/pilot.eessi-hpc.org/versions/2021.12/software/linux/x86_64/intel/haswell/modules/all as the directory to be added to MODULEPATH.
Found Lmod configuration file at /cvmfs/pilot.eessi-hpc.org/versions/2021.12/software/linux/x86_64/intel/haswell/.lmod/lmodrc.lua
Initializing Lmod...
Prepending /cvmfs/pilot.eessi-hpc.org/versions/2021.12/software/linux/x86_64/intel/haswell/modules/all to $MODULEPATH...
Environment set up to use EESSI pilot software stack, have fun!
[EESSI pilot 2021.12] $
```
