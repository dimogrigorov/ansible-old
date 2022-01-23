#!/usr/bin/python

import socket
import os
import sys

try:
    HAS_PYHP = True
    from pyhpecw7.features.config import Config
    from pyhpecw7.features.file_copy import FileCopy
    from pyhpecw7.comware import HPCOM7
    from pyhpecw7.features.errors import *
    from pyhpecw7.errors import *
except ImportError as ie:
    HAS_PYHP = False


def write_diffs(diff_file, diffs, full_diffs):

    with open(diff_file, 'w+') as diff:
        diff.write("#######################################\n")
        diff.write('########## SUMMARY OF DIFFS ###########\n')
        diff.write("#######################################\n")
        diff.write('\n\n')
        diff.write('\n'.join(diffs))
        diff.write('\n\n\n')
        diff.write("#######################################\n")
        diff.write('FULL DIFFS AS RETURNED BACK FROM SWITCH\n')
        diff.write("#######################################\n")
        diff.write('\n\n')
        diff.write('\n'.join(full_diffs))
        diff.write('\n')


def safe_fail(module, device=None, **kwargs):
    if device:
        device.close()
    module.fail_json(**kwargs)


def safe_exit(module, device=None, **kwargs):
    if device:
        device.close()
    module.exit_json(**kwargs)


def main():
    module = None

    if not HAS_PYHP:
        safe_fail(module, msg='There was a problem loading from the pyhpecw7 '
                  + 'module.', error=str(ie))

    config_file='./configs/demo.cfg'
    diff_file='./configs/demo-diff.diff'
    commit_changes=True
    port=830
    hostname='10.5.200.207'
    username='hp'
    password='hp123'

    device_args = dict(host=hostname, username=username,
                       password=password, port=port)

    device = HPCOM7(timeout=60, **device_args)

    changed = False

    if os.path.isfile(config_file):
        file_exists = True
    else:
        safe_fail(module, msg='Cannot find/access config_file:\n{0}'.format(
            config_file))

    try:
        device.open()
    except ConnectionError as e:
        safe_fail(module, device, msg=str(e),
                  descr='error opening connection to device')

    if file_exists:
        basename = os.path.basename(config_file)
        try:
            copy = FileCopy(device,
                            src=config_file,
                            dst='flash:/{0}'.format(basename))
            copy.transfer_file()
            cfg = Config(device, config_file)
        except PYHPError as fe:
            safe_fail(module, device, msg=str(fe),
                      descr='file transfer error')

    if diff_file:
        diffs, full_diffs = cfg.compare_config()
        write_diffs(diff_file, diffs, full_diffs)
    else:
        diffs = 'None.  diff_file param not set in playbook'

    cfg.build(stage=True)

    active_files = {}
    if device.staged:
        active_files = dict(backup='flash:/safety_file.cfg',
                            startup='flash:/startup.cfg',
                            config_applied='flash:/' + basename)
        if commit_changes:
            try:
                switch_response = device.execute_staged()
                # TODO: check of "ok" or errors?
            except NCError as err:
                if err.tag == 'operation-failed':
                    safe_fail(module, device, msg='Config replace operation'
                              + ' failed.\nValidate the config'
                              + ' file being applied.')
            except PYHPError as e:
                safe_fail(module, device, msg=str(e),
                          descr='error during execution')

            changed = True

    results = {}
    results['changed'] = changed
    results['active_files'] = active_files
    results['commit_changes'] = commit_changes
    results['diff_file'] = diff_file
    results['config_file'] = config_file
    sys.exit(0)
from ansible.module_utils.basic import *
main()
