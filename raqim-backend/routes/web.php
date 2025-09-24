<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

Route::get('/', function () {
    return redirect('/admin');
});

// Authentication Routes
Route::redirect('/login', '/admin/login')->name('login');
Route::post('/logout', function () {
    auth()->logout();
    return redirect('/');
})->name('logout');