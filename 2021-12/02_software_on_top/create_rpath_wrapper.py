#!/usr/bin/env python

import os
import tempfile
import glob

from easybuild.tools.options import set_up_configuration
from easybuild.tools.toolchain import toolchain as ebtc
from easybuild.tools.toolchain.toolchain import Toolchain

def main():
    set_up_configuration(silent=True)
    tc = Toolchain(name="system", version="0.1")

    # Expect rpath_filter_dirs and rpath_include_dirs as environment variables of
    # ,-separated lists by default. We might want to allow different separators.
    # E.g. ":" could be used to get a similar syntax to PATH and LD_LIBRARY_PATH
    separator = ','
    rpath_filter_dirs=None
    if "RPATH_FILTER_DIRS" in os.environ:
        rpath_filter_dirs=os.environ["RPATH_FILTER_DIRS"].split(separator)
    rpath_include_dirs=None
    if "RPATH_INCLUDE_DIRS" in os.environ:
        rpath_include_dirs=os.environ["RPATH_INCLUDE_DIRS"].split(separator)

    tc.prepare_rpath_wrappers(
            rpath_filter_dirs=rpath_filter_dirs,
            rpath_include_dirs=rpath_include_dirs
            )

    # Find location of rpath wrappers
    wrappers_base_path = glob.glob(tempfile.gettempdir() + "/tmp*/" + ebtc.RPATH_WRAPPERS_SUBDIR)[0]
    newPATH = os.environ["PATH"]
    for wrapperdir in os.listdir(wrappers_base_path):
        wholepath = os.path.join(wrappers_base_path, wrapperdir)
        newcmd = os.path.join(wholepath, os.listdir(wholepath)[0])
        # print(f"Setting up wrapper {newcmd}")

        newPATH = ":".join([wholepath, newPATH])

    print("export PATH="+newPATH)

if __name__ == "__main__":
    main()
