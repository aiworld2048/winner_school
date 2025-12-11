<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('essays', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->longText('instructions')->nullable(); // Rich text instructions for students
            $table->foreignId('subject_id')->constrained('subjects')->onDelete('cascade');
            $table->foreignId('class_id')->constrained('classes')->onDelete('cascade');
            $table->foreignId('academic_year_id')->constrained('academic_years')->onDelete('cascade');
            $table->foreignId('teacher_id')->constrained('users')->onDelete('cascade');
            $table->date('due_date');
            $table->time('due_time')->nullable();
            $table->integer('word_count_min')->nullable(); // Minimum word count
            $table->integer('word_count_max')->nullable(); // Maximum word count
            $table->decimal('total_marks', 8, 2)->default(100);
            $table->enum('status', ['draft', 'published'])->default('draft');
            $table->text('attachments')->nullable(); // JSON array of file paths
            $table->timestamps();
            
            $table->index(['teacher_id', 'status']);
            $table->index(['class_id', 'subject_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('essays');
    }
};

