<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('news', function (Blueprint $table) {
            $table->id();
            $table->string('title_ar');
            $table->string('title_en');
            $table->string('slug')->unique();
            $table->text('excerpt_ar');
            $table->text('excerpt_en');
            $table->longText('content_ar');
            $table->longText('content_en');
            $table->string('featured_image');
            $table->json('gallery')->nullable();
            $table->foreignId('author_id')->constrained('users');
            $table->enum('category', ['announcement', 'update', 'event', 'article', 'tutorial']);
            $table->json('tags')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_published')->default(false);
            $table->integer('views_count')->default(0);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('news');
    }
};