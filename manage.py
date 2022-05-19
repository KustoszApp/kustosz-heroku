#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    """Run administrative tasks."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "kustosz.settings")

    # When running, app will be stored in /app/
    # When building, we are in temporary directory with random name,
    # with $BUILD_DIR envvar pointing to what will become /app/
    #
    # Heroku wants to run `collectstatic` during build phase, which
    # means all our paths need to be relative or start with $BUILD_DIR
    #
    # There doesn't seem to be documented way of checking which phase
    # we are in, but BPLOG_PREFIX seems like a good bet - it's not set
    # in runtime by default, and what is the chance that user sets it
    # manually to exactly the same value as Heroku does?
    BPLOG_PREFIX = os.environ.get('BPLOG_PREFIX')
    if BPLOG_PREFIX == 'buildpack.python':
        BUILD_DIR = os.environ.get('BUILD_DIR')
        os.environ['KUSTOSZ_BASE_DIR'] = f"{BUILD_DIR}/kustosz/"
        os.environ['ENV_FOR_DYNACONF'] = 'build'

    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
