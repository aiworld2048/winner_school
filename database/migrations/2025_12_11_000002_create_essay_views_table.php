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
        Schema::create('essay_views', function (Blueprint $table) {
            $table->id();
            $table->foreignId('essay_id')->constrained('essays')->onDelete('cascade');
            $table->foreignId('student_id')->constrained('users')->onDelete('cascade');
            $table->decimal('amount', 10, 2)->default(100.00);
            $table->timestamps();
            
            $table->unique(['essay_id', 'student_id']);
            $table->index(['student_id', 'essay_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('essay_views');
    }
};

