<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('video_lesson_views', function (Blueprint $table) {
            $table->id();
            $table->foreignId('video_lesson_id')->constrained('video_lessons')->onDelete('cascade');
            $table->foreignId('student_id')->constrained('users')->onDelete('cascade');
            $table->unsignedInteger('amount')->default(0);
            $table->timestamps();

            $table->unique(['video_lesson_id', 'student_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('video_lesson_views');
    }
};
