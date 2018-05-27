# This file is part of rinohtype, the Python document preparation system.
#
# Copyright (c) Brecht Machiels.
#
# Use of this source code is subject to the terms of the GNU Affero General
# Public License v3. See the LICENSE file or http://www.gnu.org/licenses/.

import pytest

import os

from glob import glob

from regression import render_rst_file


RST_PATH = os.path.join(os.path.dirname(__file__), 'rst')


def collect_tests():
    for rst_path in glob(os.path.join(RST_PATH, '*.rst')):
        filename = os.path.basename(rst_path)
        test_name, _ = os.path.splitext(filename)
        yield test_name


@pytest.mark.parametrize('test_name', collect_tests())
def test(test_name, tmpdir):
    rst_path = os.path.join(RST_PATH, test_name + '.rst')
    if test_name.startswith('sphinx_'):
        from sphinx.application import Sphinx
        from rinoh.frontend.sphinx import nodes    # load Sphinx docutils nodes

        Sphinx(srcdir=tmpdir.strpath, confdir=None, outdir=tmpdir.strpath,
               doctreedir=tmpdir.strpath, buildername='dummy', status=None)
    render_rst_file(rst_path, test_name, RST_PATH, tmpdir)
