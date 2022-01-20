# EESSI hackathon Jan'22 - exporting EESSI to a tarball and/or container image

Notes: https://hackmd.io/2YpzQGgUSDyTvW3ILulzwA

### Purpose of this script
There are a couple of scenarios where you'd want your software stack preserved and frozen in time. One of them could be offline use of this stack but what we primarily aim for is frozen image of software stack that can be published togehter with source data that accompanies some scientific paper. Idea here is that results in the paper can be reproduced independently for anyone that cares about them and wants to understand how the paper reached conclusions it did.

This script will take your EESSI environment you currently have loaded up and pack it up in a singularity container. There are a couple of ways you can influence the result:

`-g`: pack generic modules instead of cpu specific ones
If you want to make sure that resulting container is will run on just about any kind of machine without issues and without performance enhancing optimizations, use this option. Without it it can happen that you hit "Illegal Instruction" error, for example if you want to run avx512 tuned binaries on a system that doesn't support avx512.

`-n`: how you want to name your container image. Default is derived from the name of the last loaded module.

`-v`: String that you want to append to the version of the container image. It always includes date, which is fine grained enough based on the frequency of EESSI updates.

`-d` destination on the filesystem where you want your container image to land. Build always happens in /tmp and both it and this destination are checked for enough disk space before starting.

`-a` Author (you) of the image. Only mandatory field as there's no decent way to autofill this.

Build process itself takes a couple of minutes, depending on how warm your cvmfs caches are and how fast your underlying filesystem is. 

## Known issues
As it was developed on top of pilot EESSI, there are for sure going to be some changes in the future EESSI init scripts that might break things here. Ideally we should aim for EESSI init scripts to sense when they're run in an offline container and act accordingly.

For example, if you have a container with generic modules, EESSI init still detects your CPU architecture and tries to load optimized modules by default. Which makes sense in HPC environment but not for this case. 

## TODOs
There are a couple of ways this can develop. Two ideas already being looked into are integration of EESSI test suites once they're available and assigning of some form of persistent identifiers to resulting containers by which they can be referred to in papers etc. Here we assume that long term storage of these containers (which can be quite large) will be handled by the research institution ;)
