<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('courses', function (Blueprint $table) {
            $table->id();
            $table->string('title_ar');
            $table->string('title_en');
            $table->string('slug')->unique();
            $table->text('description_ar');
            $table->text('description_en');
            $table->text('objectives_ar')->nullable();
            $table->text('objectives_en')->nullable();
            $table->text('requirements_ar')->nullable();
            $table->text('requirements_en')->nullable();
            $table->string('thumbnail');
            $table->string('preview_video')->nullable();
            $table->foreignId('instructor_id')->constrained('users');
            $table->foreignId('category_id')->constrained('categories');
            $table->enum('level', ['beginner', 'intermediate', 'advanced']);
            $table->string('language')->default('ar');
            $table->integer('duration_hours');
            $table->decimal('price', 10, 2);
            $table->decimal('discount_price', 10, 2)->nullable();
            $table->boolean('is_free')->default(false);
            $table->boolean('is_featured')->default(false);
            $table->enum('status', ['draft', 'pending', 'published', 'archived'])->default('draft');
            $table->integer('enrolled_count')->default(0);
            $table->decimal('rating', 3, 2)->default(0);
            $table->integer('reviews_count')->default(0);
            $table->integer('lessons_count')->default(0);
            $table->json('what_will_learn')->nullable();
            $table->json('target_audience')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('courses');
    }
};