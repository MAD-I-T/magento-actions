<?php

namespace Deployer;

use Deployer\Exception\Exception;

require 'recipe/common.php';



// Servers
import('hosts.yaml');

set('writable_use_sudo', '{{write_use_sudo}}');
set('writable_mode', 'chmod'); // chmod, chown, chgrp or acl.
set('deploy_path', "{{deploy_path_custom}}");
set('keep_releases', "{{deploy_keep_releases}}");


// Magento root
set('magento_root', 'magento');

// Configuration
set(
    'shared_files', [
        '{{magento_root}}/app/etc/env.php',
        '{{magento_root}}/var/.maintenance.ip',
    ]
);
set(
    'shared_dirs', [
        '{{magento_root}}/pub/media'
    ]
);
set(
    'writable_dirs', [
        '{{magento_root}}/var',
        '{{magento_root}}/pub/static',
        '{{magento_root}}/pub/media',
    ]
);


// Disable uneccessary tasks
task('deploy:update_code')->disable();


// Tasks
desc('Unpack bucket-commit');
task(
    'deploy:unpack-bucket', function() {
    try {
        cd('{{host_bucket_path}}');
        run('mkdir -p temp');
        run('tar xfz {{bucket-commit}} -C temp');

        if (test('[ -d temp/magento ]')) {
            info('releasing magento');
            run('cp -rf temp/magento {{release_path}}');
        }
        else info('magento backend release skipped');

        if (test('[ -d temp/pwa-studio ]')) {
            info('releasing pwa-studio');
            run('cp -rf temp/pwa-studio {{release_path}}');
        }else info('pwa-studio release skipped');

        if (test('[ -d temp/deployer ]')) {
            info('releasing deployer');
            run('cp -rf temp/deployer {{deploy_path}}');
        }else info('deployer release skipped');

        run('mv {{bucket-commit}} {{bucket-commit}}.back');
        run('rm temp -rf');
    } catch (\Exception $e) {
        throw new Exception('No bucket-commit file found. '.$e->getMessage());
    }
}
);

// Main Tasks
desc('Deploy bucket');
task(
    'deploy-bucket', [
        'deploy:info',
        'deploy:setup',
        'deploy:lock',
        'deploy:release',
        'deploy:unpack-bucket'
    ]
);

desc('Deploy release');
task(
    'deploy', [
        'deploy:shared',
        'deploy:writable',
        'deploy:symlink',
        'deploy:unlock',
        'deploy:cleanup',
        'deploy:success'
    ]
);


//task('deploy:writable')->disable();
desc('Deploy release without permission check aka writable_mode');
task(
    'deploy:no-permission-check', [
        'deploy:shared',
        'deploy:symlink',
        'deploy:unlock',
        'deploy:cleanup',
        'deploy:success'
    ]
);

desc('Deploy release without permission check and pwa only');
task(
    'deploy:no-permission-check:pwa-only', [
        'deploy:symlink',
        'deploy:unlock',
        'deploy:cleanup',
        'deploy:success'
    ]
);

// [Optional] If deploy fails automatically unlock.
after('deploy:failed', 'deploy:unlock');