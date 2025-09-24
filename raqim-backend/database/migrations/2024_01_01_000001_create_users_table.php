<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->string('phone')->nullable();
            $table->enum('role', ['admin', 'instructor', 'student'])->default('student');
            $table->string('avatar')->nullable();
            $table->text('bio')->nullable();
            $table->json('skills')->nullable();
            $table->string('country')->nullable();
            $table->string('city')->nullable();
            $table->date('birth_date')->nullable();
            $table->enum('status', ['active', 'inactive', 'banned'])->default('active');
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};