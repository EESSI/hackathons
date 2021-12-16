import os
import reframe as rfm
import reframe.utility.sanity as sn

@rfm.simple_test
class WrfConusDownload(rfm.RunOnlyRegressionTest):
    descr = 'WRF benchmarks download Conus'
    valid_systems = ['*']
    valid_prog_environs = ['builtin']
    executable = 'wget'
    executable_opts = [
        'http://www2.mmm.ucar.edu/wrf/bench/conus12km_v3911/bench_12km.tar.bz2'
    ]
    postrun_cmds = [
        'bunzip2 bench_12km.tar.bz2',
        'tar -xf bench_12km.tar'
    ]

    @sanity_function
    def validate_download(self):
        return sn.assert_true(os.path.exists('bench_12km'))



@rfm.simple_test
class WrfCheck(rfm.RunOnlyRegressionTest):
    def __init__(self):
        self.valid_systems = ['*']
        self.valid_prog_environs = ['builtin']
        self.modules = ['WRF']
        self.executable = 'wrf.exe'

    @run_after('init')
    def inject_dependencies(self):
        self.depends_on('WrfConusDownload')

    @require_deps
    def set_sourcedir(self, WrfConusDownload):
        self.sourcesdir = WrfConusDownload(part='default', environ='builtin').stagedir

        self.readonly_files = ['bench_12km']
        self.prerun_cmds = [
            f'ln -s `dirname $(which wrf.exe)`/../run/* .',
            f'rm namelist.input',
            f'ln -s bench_12km/* .',
        ]
        self.num_tasks = 16

    @sanity_function
    def validate_test(self):
        return sn.assert_found(r'SUCCESS COMPLETE WRF', 'rsl.out.0000')
