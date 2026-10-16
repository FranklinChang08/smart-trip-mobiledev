<?php

return [
    'paths' => ['api/*', 'storage/*'],

    'allowed_methods' => ['*'],


    'allowed_origins_patterns' => [],
    'allowed_origins' => ['*'], // Atau sesuaikan dengan origin Flutter web Anda

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,
];
