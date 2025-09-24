<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jobs', function (Blueprint $table) {
            $table->id();
            $table->string('title_ar');
            $table->string('title_en');
            $table->string('company_name');
            $table->string('company_logo')->nullable();
            $table->text('description_ar');
            $table->text('description_en');
            $table->text('requirements_ar');
            $table->text('requirements_en');
            $table->enum('type', ['full_time', 'part_time', 'contract', 'internship', 'freelance']);
            $table->enum('location_type', ['onsite', 'remote', 'hybrid']);
            $table->string('location');
            $table->string('salary_range')->nullable();
            $table->string('experience_level');
            $table->json('skills')->nullable();
            $table->string('application_link')->nullable();
            $table->string('contact_email');
            $table->boolean('is_active')->default(true);
            $table->boolean('is_featured')->default(false);
            $table->integer('views_count')->default(0);
            $table->integer('applications_count')->default(0);
            $table->timestamp('deadline')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jobs');
    }
};