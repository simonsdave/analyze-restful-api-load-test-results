import optparse


__version__ = '0.9.0'


class CommandLineParser(optparse.OptionParser):

    def __init__(self):
        optparse.OptionParser.__init__(
            self,
            'usage: %prog [options]',
            description='This utility analyzes load test results')

        default = 0.1
        help_msg = 'max slope for all requests by type - default = %.2f' % default
        self.add_option(
            '--max-slope',
            action='store',
            dest='max_slope',
            default=default,
            type='float',
            help=help_msg)

        default = None
        help_msg = 'pdf filename for graphs - default = %s' % default
        self.add_option(
            '--graphs',
            action='store',
            dest='graphs',
            default=default,
            type='string',
            help=help_msg)

    def parse_args(self, *args, **kwargs):
        (clo, cla) = optparse.OptionParser.parse_args(self, *args, **kwargs)
        if 0 != len(cla):
            self.error('invalid command line args')
        return (clo, cla)
