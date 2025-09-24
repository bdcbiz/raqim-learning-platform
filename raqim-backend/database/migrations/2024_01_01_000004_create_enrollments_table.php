<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('course_id')->constrained('courses');
            $table->enum('status', ['active', 'completed', 'suspended', 'cancelled'])->default('active');
            $table->decimal('progress', 5, 2)->default(0);
            $table->integer('completed_lessons')->default(0);
            $table->timestamp('enrolled_at');
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('last_accessed_at')->nullable();
            $table->boolean('certificate_issued')->default(false);
            $table->string('certificate_number')->nullable();
            $table->timestamp('certificate_issued_at')->nullable();
            $table->json('lesson_progress')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'course_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('enrollments');
    }
};