<?php
/**
 * Copyright © Magento, Inc. All rights reserved.
 * See COPYING.txt for license details.
 */

return [
    'db-host' => 'mysql',
    'db-user' => 'root',
    'db-password' => 'magento',
    'db-name' => 'magento',
    'db-prefix' => '',
    'backend-frontname' => 'backend',
    'admin-user' => \Magento\TestFramework\Bootstrap::ADMIN_NAME,
    'admin-password' => \Magento\TestFramework\Bootstrap::ADMIN_PASSWORD,
    'admin-email' => \Magento\TestFramework\Bootstrap::ADMIN_EMAIL,
    'admin-firstname' => \Magento\TestFramework\Bootstrap::ADMIN_FIRSTNAME,
    'admin-lastname' => \Magento\TestFramework\Bootstrap::ADMIN_LASTNAME,
    'amqp-host' => 'rabbitmq',
    'amqp-port' => '5672',
    'amqp-user' => 'magento',
    'amqp-password' => 'magento',
    'es-hosts' => "elasticsearch:9200",
    'es-user'=> "",
    'es-pass'=> ""
];
