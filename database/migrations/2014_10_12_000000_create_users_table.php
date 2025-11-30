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
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('user_name')->unique();
            $table->string('name')->nullable();
            $table->string('phone')->nullable();
            $table->string('email')->nullable()->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->string('profile', 2000)->nullable();
            $table->decimal('balance', 64, 2)->default(0);
            $table->integer('status')->default(1);
            $table->integer('is_changed_password')->default(1);
            $table->unsignedBigInteger('teacher_id')->nullable()->comment('Head Teacher ID - Student belong to Head Teacher');
            $table->unsignedBigInteger('payment_type_id')->nullable();
            $table->string('account_name')->nullable();
            $table->string('account_number')->nullable();
            $table->string('type');
            //$table->string('referral_code')->default('winnerschool');
            $table->rememberToken();
            $table->timestamps();
            
            // Foreign keys - teacher_id is actually head teacher_id (for Head Teacher->Student relationship)
            $table->foreign('teacher_id')->references('id')->on('users')->onDelete('cascade');
            
            // Indexes for performance
            $table->index('status');
            $table->index('type');
            $table->index('teacher_id'); // Index for Head Teacher->Student lookups
            $table->index('payment_type_id');
            $table->index('is_changed_password');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
