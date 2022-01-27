# EESSI hackathon Jan'22 - workflow to propose additions to EESSI software stack

Updates since the last hackaton in December 2021:
------------------------------------------------

- script to build software for EESSI added
- automatic build script expanded to include the automatic EESSI software build as well
- site-config script expanded: definition for various SLURM partitions added. This script also contains the switch to build software either for an existing software stack with for example EasyBuild, but other software installation scripts should work as well, or build for EESSI. It is also possible to do both in one pull request. 

The way the system is set up right now allows HPC sites adopt them fairly easy and can build software for either their local software stack and/or CVMFS system, or contribute to the EESSI projct by building software. The aim is to push all the relevant site configurations, like paths etc, in the `site-config` file. So even if a HPC site currently is not using CVMFS, due to the automated software build it still can benefit from the EESSI project by using only one part of the project. 

Requirements:
------------

- installation of Singularity. Tested with version `3.8.4` and `3.8.5`
- running git-bot to submit jobs to the cluster

Note: During the testing we noticed some issues around `fuse-overlayfs` which are currently not fully understood. This might affect the build for the software stack but does not affect the build for EESSI. We are working on this (see this (PR# 232)[https://github.com/containers/fuse-overlayfs/issues/232]

Usage:
------

The bot is submitting a Unified Resource Location, like for example a full path, to the `automatic-build.sh` file which does expect this as the first, and right now only, argument, and starts the build by running the script:
`$ automatic-build.sh /path/to/handle/`
where the 'handle' could be some kind of way to relate back to the original PR, and the 'softwarelist.yaml' file in that directory contains the to be build software in the yml file format. 
It is also possible to just include the name of the EasyConfig file in a simple text file named 'softwarelist.txt'. Right now the file names are fixed to these names. 

The `automatic-build.sh` kicks off the builds as defined in the `site-config` file. This way, the software can be build on remote systems as well as long as the local SLURM has access to them. 

Disclaimer:
----------

This is work in progress and not quite ready for production right now.

Notes: https://hackmd.io/6V91CHRWRtuutANPaZRVPw
