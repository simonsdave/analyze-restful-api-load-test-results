"""This module contains unit tests for the ```__init__``` module."""

import sys
import unittest

import mock

from .. import CommandLineParser


class TestCommandLineParser(unittest.TestCase):

    def test_no_args(self):
        with mock.patch.object(sys, 'argv', ['boo.py']):
            clp = CommandLineParser()
            (clo, cla) = clp.parse_args()

            self.assertIsNotNone(clo.max_slope)
            self.assertIsNotNone(clo.graphs)
