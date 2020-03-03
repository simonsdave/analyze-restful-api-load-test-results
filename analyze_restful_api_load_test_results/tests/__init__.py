"""This module contains unit tests for the ```__init__``` module."""

import datetime
import sys
import unittest
import uuid

import dateutil
import mock

from .. import CommandLineParser
from .. import Main
from .. import Response


class TestCommandLineParser(unittest.TestCase):

    def test_no_args(self):
        with mock.patch.object(sys, 'argv', ['boo.py']):
            clp = CommandLineParser()
            (clo, cla) = clp.parse_args()

            self.assertEqual(type(clo.max_slope), float)
            self.assertEqual(clo.graphs, '/dev/null')

    def test_max_slope_arg(self):
        max_slope = 5.6
        with mock.patch.object(sys, 'argv', ['boo.py', '--max-slope', max_slope]):
            clp = CommandLineParser()
            (clo, cla) = clp.parse_args()

            self.assertEqual(clo.max_slope, max_slope)
            self.assertEqual(clo.graphs, '/dev/null')

    def test_graphs_arg(self):
        filename = uuid.uuid4().hex

        with mock.patch.object(sys, 'argv', ['boo.py', '--graphs', filename]):
            clp = CommandLineParser()
            (clo, cla) = clp.parse_args()

            self.assertEqual(type(clo.max_slope), float)
            self.assertEqual(clo.graphs, filename)

        with mock.patch.object(sys, 'argv', ['boo.py', '--graphs=%s' % filename]):
            clp = CommandLineParser()
            (clo, cla) = clp.parse_args()

            self.assertEqual(type(clo.max_slope), float)
            self.assertEqual(clo.graphs, filename)

    def test_bad_args(self):
        def error_patch(clp, message):
            self.assertIsNotNone(clp)
            self.assertIsNotNone(message)

        with mock.patch.object(sys, 'argv', ['boo.py', 'bindle', 'berry', 'haggle']):
            with mock.patch('optparse.OptionParser.error', error_patch):
                clp = CommandLineParser()
                (clo, cla) = clp.parse_args()


class TestResponse(unittest.TestCase):

    def test_ctr(self):
        timestamp = datetime.datetime(2019, 3, 26).replace(tzinfo=dateutil.tz.tzutc())
        request_type = 'Health-Check'
        success = 1
        vu = 'bc463d3dc4ab433b9f53de322f0c7138'
        response_time = 6.77

        response = Response(request_type, timestamp, success, vu, response_time)

        self.assertEqual(response.request_type, request_type)
        self.assertEqual(response.timestamp, timestamp)
        self.assertEqual(response.success, success)
        self.assertEqual(response.vu, vu)
        self.assertEqual(response.response_time, response_time)


class TestMainLoadData(unittest.TestCase):

    def test_happy_path(self):
        responses_data = [
            '2017-07-19T01:25:00.00000000Z\tPUT\t1\t1\t100',
            '2017-07-19T01:25:01.00000000Z\tPUT\t1\t1\t200',
            '2017-07-19T01:25:02.00000000Z\tPUT\t1\t1\t300',
            '2017-07-19T01:25:03.00000000Z\tPUT\t1\t1\t400',
            '2017-07-19T01:25:04.00000000Z\tPUT\t1\t1\t500',
            '2017-07-19T01:25:05.00000000Z\tPUT\t1\t1\t600',
            '2017-07-19T01:25:06.00000000Z\tPUT\t1\t1\t700',
            '2017-07-19T01:25:07.00000000Z\tPUT\t1\t1\t800',
            '2017-07-19T01:25:08.00000000Z\tPUT\t1\t1\t900',
            '2017-07-19T01:25:09.00000000Z\tPUT\t1\t1\t900',
        ]
        with mock.patch('sys.stdin', responses_data):
            main = Main()
            main.load_data()
