<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class IntlServiceProvider extends ServiceProvider
{
    public function register()
    {
        // Include the NumberFormatter polyfill
        require_once app_path('Helpers/NumberFormatter.php');
    }

    public function boot()
    {
        //
    }
}