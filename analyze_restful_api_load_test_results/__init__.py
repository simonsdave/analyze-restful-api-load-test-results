import datetime
import optparse
import re
import sys

import dateutil.parser
import numpy
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt


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

        default = '/dev/null'
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


class Response(object):

    def __init__(self, request_type, timestamp, success, vu, response_time):
        object.__init__(self)

        self.request_type = request_type
        self.timestamp = timestamp
        self.success = success
        # k6 calls them virtual users (vu) and gives each vu a unique integer identifier
        # locust calls them locusts and gives each one a unique identifier
        self.vu = vu
        self.response_time = response_time

    def get_seconds_since_start(self, responses):
        return (self.timestamp - responses.first_timestamp).total_seconds()

    def _get_bucket_size_in_seconds(self, responses):
        total_number_seconds_in_test = (responses.last_timestamp - responses.first_timestamp).total_seconds()
        total_number_of_buckets_so_things_look_ok = 100
        return total_number_seconds_in_test / total_number_of_buckets_so_things_look_ok

    def get_seconds_since_start_bucket(self, responses):
        seconds_since_start = int(round(self.get_seconds_since_start(responses), 0))
        return seconds_since_start - (seconds_since_start % self._get_bucket_size_in_seconds(responses))


class Responses(object):

    def __init__(self):
        object.__init__(self)

        self.responses = []
        self.responses_by_request_type = {}
        self.responses_by_vus = {}
        self.first_timestamp = datetime.datetime(2990, 1, 1).replace(tzinfo=dateutil.tz.tzutc())
        self.last_timestamp = datetime.datetime(1990, 1, 1).replace(tzinfo=dateutil.tz.tzutc())

    def add(self, response):
        self.responses.append(response)

        if response.request_type not in self.responses_by_request_type:
            self.responses_by_request_type[response.request_type] = []
        self.responses_by_request_type[response.request_type].append(response)

        if response.vu not in self.responses_by_vus:
            self.responses_by_vus[response.vu] = []
        self.responses_by_vus[response.vu].append(response)

        self.first_timestamp = min(response.timestamp, self.first_timestamp)
        self.last_timestamp = max(response.timestamp, self.last_timestamp)

    def request_types(self):
        return [request_type for request_type in self.responses_by_request_type.keys()]

    def responses_for_request_type(self, request_type):
        return self.responses_by_request_type[request_type]

    def successes_for_request_type(self, request_type):
        return [response for response in self.responses_by_request_type[request_type] if response.success]

    def failures_for_request_type(self, request_type):
        return [response for response in self.responses_by_request_type[request_type] if not response.success]

    def number_of_vus(self):
        return len(self.responses_by_vus.keys())

    def __len__(self):
        return len(self.responses)


class Main(object):

    def load_data(self):
        responses = Responses()

        reg_ex_pattern = (
            r'^\s*'
            r'(?P<timestamp>.+)\t'
            r'(?P<request_type>.+)\t'
            r'(?P<success>\d{1})\t'
            r'(?P<vu>.+)\t'
            r'(?P<response_time>\d*\.\d+|\d+)'
            r'\s*$'
        )
        reg_ex = re.compile(reg_ex_pattern)

        line_number = 0
        for line in sys.stdin:
            line_number += 1
            try:
                match = reg_ex.match(line)
                if match:
                    timestamp = dateutil.parser.parse(match.group('timestamp'))
                    if not timestamp.tzinfo:
                        timestamp = timestamp.replace(tzinfo=dateutil.tz.tzlocal())
                    request_type = match.group('request_type')
                    success = int(match.group('success'))
                    vu = match.group('vu')
                    response_time = float(match.group('response_time'))

                    response = Response(request_type, timestamp, success, vu, response_time)
                    responses.add(response)
                else:
                    print('ERROR - %d: invalid input format - %s' % (line_number, line.strip()))
            except Exception as ex:
                print('ERROR - %d: %s' % (line_number, ex))
                print('>>>%s<<<' % line)

        return responses

    def numerical_analysis(self, responses, max_slope):
        """Returns 0 on success and 1 on failure."""
        overall_title = '%s @ %s from %s to %s' % (
            '{:,}'.format(len(responses)),
            '{:,}'.format(responses.number_of_vus()),
            responses.first_timestamp,
            responses.last_timestamp,
        )
        line = '=' * len(overall_title)
        print(line)
        print(overall_title)
        print(line)
        print('')

        percentiles = [50, 95, 99]
        fmt = '%-25s %5d %5d %9.4f' + '%9.0f' * (2 + len(percentiles) + 1)
        request_types = responses.request_types()
        request_types.sort()

        title_fmt = '%-25s %5s %5s ' + '%9s' * (3 + len(percentiles) + 1)
        args = [
            'Request Type',
            'Ok',
            'Error',
            'm',
            'b',
            'Min',
        ]
        args.extend(percentiles)
        args.append('Max')
        title = title_fmt % tuple(args)
        print(title)
        print('-' * len(title))

        return_value = 0

        for request_type in request_types:
            responses_for_request_type = responses.responses_for_request_type(request_type)

            seconds_since_start = [
                response.get_seconds_since_start(responses) for response in responses_for_request_type
            ]

            response_times = [response.response_time for response in responses_for_request_type]

            degree_of_the_fitting_polynomial = 1
            m, b = numpy.polyfit(seconds_since_start, response_times, degree_of_the_fitting_polynomial)
            args = [
                request_type,
                len(responses.successes_for_request_type(request_type)),
                len(responses.failures_for_request_type(request_type)),
                m,
                b,
                min(response_times),
            ]
            args.extend(numpy.percentile(numpy.array(response_times), percentiles))
            args.append(max(response_times))
            print(fmt % tuple(args))

            if max_slope < abs(m):
                return_value = 1

        print('')
        print('=' * len(overall_title))

        return return_value

    def generate_graphs(self, responses, graphs):
        with PdfPages(graphs) as pdf:
            request_types = responses.request_types()
            request_types.sort()

            for request_type in request_types:
                responses_for_request_type = responses.responses_for_request_type(request_type)

                response_times_in_buckets = {}
                for response in responses_for_request_type:
                    seconds_since_start_bucket = response.get_seconds_since_start_bucket(responses)
                    if seconds_since_start_bucket not in response_times_in_buckets:
                        response_times_in_buckets[seconds_since_start_bucket] = []
                    response_times_in_buckets[seconds_since_start_bucket].append(response.response_time)

                xs = [x for x in response_times_in_buckets.keys()]
                xs.sort()

                tabloid_width = 17
                tabloid_height = 11
                plt.figure(figsize=(tabloid_width, tabloid_height))

                column_labels = ['m', 'b']
                row_labels = []
                row_colours = []
                cells = []

                m_fmt = '%.4f'
                b_fmt = '%.0f'

                ys = [max(response_times_in_buckets.get(x, [0])) for x in xs]
                m, b = numpy.polyfit(xs, ys, 1)
                cells.append([m_fmt % m, b_fmt % b])
                row_labels.append('max')
                row_colours.append('yellow')
                plt.plot(xs, ys, row_colours[-1], label=row_labels[-1], zorder=1)

                percentiles = [99, 90]
                percentile_colours = ['orange', 'red']
                zorders = [2, 3]
                for percentile, percentile_colour, zorder in zip(percentiles, percentile_colours, zorders):
                    ys = [numpy.percentile(response_times_in_buckets.get(x, [0]), percentile) for x in xs]
                    m, b = numpy.polyfit(xs, ys, 1)
                    cells.append([m_fmt % m, b_fmt % b])
                    # see TeX markup @ https://matplotlib.org/users/mathtext.html
                    # for how the superscripting works
                    row_labels.append('$%d^{th} percentile$' % percentile)
                    row_colours.append(percentile_colour)
                    plt.plot(
                        xs,
                        ys,
                        row_colours[-1],
                        label=row_labels[-1],
                        zorder=zorder)

                ys = [min(response_times_in_buckets.get(x, [0])) for x in xs]
                m, b = numpy.polyfit(xs, ys, 1)
                cells.append([m_fmt % m, b_fmt % b])
                row_labels.append('min')
                row_colours.append('blue')
                plt.plot(xs, ys, row_colours[-1], label=row_labels[-1], zorder=4)

                # table of analysis results will also act as legend
                plt.table(
                    colWidths=[0.1] * 3,
                    cellText=cells,
                    rowLabels=row_labels,
                    rowColours=row_colours,
                    rowLoc='right',
                    colLabels=column_labels,
                    loc='bottom')
                # bbox=[0, -0.5, 1, 0.275])

                plt.grid(True)

                plt.xlabel(
                    'Seconds Since Test Start',
                    fontsize='large',
                    fontweight='bold')
                plt.ylabel(
                    'Response Time\n(milliseconds)',
                    fontsize='large',
                    fontweight='bold')

                hours, remainder = divmod((responses.last_timestamp - responses.first_timestamp).total_seconds(), 3600)
                minutes, _ = divmod(remainder, 60)
                title = '%s\n(%.0f%% of %s requests @ %d concurrency for %d hours %d minutes)\n' % (
                    request_type.replace('-', ' '),
                    (len(responses) * 100.0) / len(responses),
                    '{:,}'.format(len(responses)),
                    responses.number_of_vus(),
                    hours,
                    minutes)
                plt.title(
                    title,
                    fontsize='xx-large',
                    fontweight='bold')
                pdf.savefig()
                plt.close()
