"""This module runs integration tests against the project's
docker image which is typically produced as part of the CI process.
"""

import os
import subprocess
import tempfile
import unittest

from nose.util import safe_str


class IntegrationTestCase(unittest.TestCase):

    @property
    def docker_image_name(self):
        docker_image_name = os.environ.get('ANALYZE_DOCKER_IMAGE', None)
        self.assertIsNotNone(docker_image_name)
        return docker_image_name

    def docker_run(self, stdin_filename, *process_args):
        stdout_filename = tempfile.mktemp()

        with open(stdin_filename, 'r') as stdin_fp:
            with open(stdout_filename, 'w+') as stdout_fp:
                exit_code = subprocess.call(
                    process_args,
                    stdin=stdin_fp,
                    stdout=stdout_fp,
                    stderr=subprocess.STDOUT)

        stdout = []
        with open(stdout_filename, 'r') as fp:
            stdout += safe_str(fp.read()).split('\n')

        os.unlink(stdout_filename)

        return (exit_code, stdout)


class SamplesIntegrationTestCase(IntegrationTestCase):

    def test_analyze_no_graphs(self):
        (exit_code, stdout) = self.docker_run(
            os.path.join(os.path.dirname(__file__), 'stdin', 'happy_path.tsv'),
            'docker',
            'run',
            '-i',
            self.docker_image_name,
            'analyze_restful_api_load_test_results.sh')

        self.assertEqual(exit_code, 0)
        # :TODO: this is not exactly extensive validation of the stdout:-(
        self.assertEqual(len(stdout), 11)

    def test_analyze_with_graphs(self):
        graph_filename = tempfile.mktemp()

        (exit_code, stdout) = self.docker_run(
            os.path.join(os.path.dirname(__file__), 'stdin', 'happy_path.tsv'),
            'docker',
            'run',
            '-i',
            '-v',
            '%s:/graphs' % os.path.dirname(graph_filename),
            self.docker_image_name,
            'analyze_restful_api_load_test_results.sh',
            '--graphs=%s' % os.path.join('/graphs', os.path.basename(graph_filename)))

        self.assertEqual(exit_code, 0)
        # :TODO: this is not exactly extensive validation of the stdout:-(
        self.assertEqual(len(stdout), 11)

        # :TODO: was getting the error below when trying to delete graph_filename
        #   OSError: [Errno 1] Operation not permitted: '/tmp/tmpGRNKKZ'
        # os.unlink(graph_filename)
