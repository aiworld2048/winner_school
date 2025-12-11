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
        Schema::create('exam_questions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('exam_id')->constrained('exams')->onDelete('cascade');
            $table->text('question_text');
            $table->text('question_description')->nullable(); // For rich text with math equations
            $table->decimal('marks', 8, 2)->default(1.00);
            $table->integer('order')->default(0);
            $table->enum('type', ['multiple_choice', 'true_false', 'short_answer'])->default('multiple_choice');
            $table->text('correct_answer')->nullable(); // For short_answer type
            $table->timestamps();
            
            $table->index(['exam_id', 'order']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exam_questions');
    }
};

