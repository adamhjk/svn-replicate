use inc::Module::Install;

name     'SVN-Replicate';
all_from 'lib/SVN/Replicate.pm';
author   'Adam Jacob <adam@hjksolutions.com>';

build_requires 'Test::More';

requires 'Pod::Usage';

install_script 'bin/svn-replicate';

auto_install;

WriteAll;

