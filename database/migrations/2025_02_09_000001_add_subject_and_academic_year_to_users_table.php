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
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'subject_id')) {
                if (Schema::hasTable('subjects')) {
                    $table->foreignId('subject_id')
                        ->nullable()
                        ->after('class_id')
                        ->constrained('subjects')
                        ->nullOnDelete();
                } else {
                    $table->unsignedBigInteger('subject_id')
                        ->nullable()
                        ->after('class_id');
                }
            }

            if (!Schema::hasColumn('users', 'academic_year_id')) {
                if (Schema::hasTable('academic_years')) {
                    $table->foreignId('academic_year_id')
                        ->nullable()
                        ->after('subject_id')
                        ->constrained('academic_years')
                        ->nullOnDelete();
                } else {
                    $table->unsignedBigInteger('academic_year_id')
                        ->nullable()
                        ->after('subject_id');
                }
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'academic_year_id')) {
                if (Schema::hasTable('academic_years')) {
                    $table->dropForeign(['academic_year_id']);
                }
                $table->dropColumn('academic_year_id');
            }

            if (Schema::hasColumn('users', 'subject_id')) {
                if (Schema::hasTable('subjects')) {
                    $table->dropForeign(['subject_id']);
                }
                $table->dropColumn('subject_id');
            }
        });
    }
};

