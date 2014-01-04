#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import errno
from itertools import islice
import os
import platform
import re
import shutil
import sys
import unicodedata

if sys.version_info[0] == 3:
    imap = map
    os.getcwdu = os.getcwd
else:
    from itertools import imap


def create_dir(path):
    """Creates a directory atomically."""
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise


def decode(string):
    """Converts byte string to Unicode string."""
    if is_python2():
        return string.decode('utf-8', errors='replace')
    return string


def encode(string):
    """Converts Unicode string to byte string."""
    if is_python2():
        return string.encode('utf-8', errors='replace')
    return string


def encode_local(string, encoding=None):
    """Converts string into local filesystem encoding."""
    if is_python2():
        return decode(string).encode(encoding or sys.getfilesystemencoding())
    return string


def first(xs):
    it = iter(xs)
    try:
        if is_python3():
            return it.__next__()
        return it.next()
    except StopIteration:
        return None


def get_tab_entry_info(entry, separator):
    """
    Given a tab entry in the following format return needle, index, and path:

        [needle]__[index]__[path]
    """
    needle, index, path = None, None, None

    match_needle = re.search(r'(.*?)' + separator, entry)
    match_index = re.search(separator + r'([0-9]{1})', entry)
    match_path = re.search(
            separator + r'[0-9]{1}' + separator + r'(.*)',
            entry)

    if match_needle:
        needle = match_needle.group(1)

    if match_index:
        index = int(match_index.group(1))

    if match_path:
        path = match_path.group(1)

    return needle, index, path


def get_pwd():
    try:
        return os.getcwdu()
    except OSError:
        print("Current directory no longer exists.", file=sys.stderr)
        raise


def has_uppercase(string):
    if is_python3():
        return any(ch.isupper() for ch in string)
    return any(unicodedata.category(c) == 'Lu' for c in unicode(string))


def in_bash():
    return 'bash' in os.getenv('SHELL')


def is_python2():
    return sys.version_info[0] == 2


def is_python3():
    return sys.version_info[0] == 3


def is_linux():
    return platform.system() == 'Linux'


def is_osx():
    return platform.system() == 'Darwin'


def is_windows():
    return platform.system() == 'Windows'


def last(xs):
    it = iter(xs)
    tmp = None
    try:
        if is_python3():
            while True:
                tmp = it.__next__()
        else:
            while True:
                tmp = it.next()
    except StopIteration:
        return tmp


def move_file(src, dst):
    """
    Atomically move file.

    Windows does not allow for atomic file renaming (which is used by
    os.rename / shutil.move) so destination paths must first be deleted.
    """
    if is_windows() and os.path.exists(dst):
        # raises exception if file is in use on Windows
        os.remove(dst)
    shutil.move(src, dst)


def print_entry(entry):
    print(encode_local("%.1f:\t%s" % (entry.weight, entry.path)))


def print_tab_menu(needle, tab_entries, separator):
    """
    Prints the tab completion menu according to the following format:

        [needle]__[index]__[possible_match]

    The needle (search pattern) and index are necessary to recreate the results
    on subsequent calls.
    """
    for i, entry in enumerate(tab_entries):
        print(encode_local(
            '%s%s%d%s%s' % (
                needle,
                separator,
                i + 1,
                separator,
                entry.path)))


def sanitize(directories):
    clean = lambda x: decode(x) if len(x) == 1 else decode(x).rstrip(os.sep)
    return list(imap(clean, directories))


def second(xs):
    it = iter(xs)
    try:
        it.next()
        return it.next()
    except StopIteration:
        return None


def surround_quotes(string):
    """
    Bash has problems dealing with certain paths so we're surrounding all
    path outputs with quotes.
    """
    if in_bash():
        return '"{}"'.format(string)
    return string


def take(n, iterable):
    """Return first n items of an iterable."""
    return islice(iterable, n)
