This repository contains scripts, notes, etc. related to EESSI hackathons.

### Hackathons

* [1st EESSI hackathon: 13-17 Dec 2021](2021-12)

### Access

If you would like to have write access to this repository, share your GitHub handle with one of the repo managers:

* Alan (@ocaisa)
* Bob (@bedroge)
* Kenneth (@boegel)
* Thomas (@trz42)

### Policy

No pull requests required, just push directly in a subdirectory that you or the task team you're a part of manages.

### Workflow

To get started, clone the repository:

```
mkdir EESSI; cd EESSI
git clone git@github.com:EESSI/hackathons.git
cd hackathons
```

Check out the branch for the task you're working on. For example:

```
git checkout 02_software_on_top
```

To push updates, first pull down the latest changes for the branch you're working on:

```
git pull origin 02_software_on_top
```

Then commit and push your stuff:

```
cd 2021-12/02_software_on_top
git add stuff.txt script.sh
git commit -m "update for my stuff"
git push origin main
```
