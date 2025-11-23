<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Exam extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'code',
        'description',
        'subject_id',
        'class_id',
        'academic_year_id',
        'exam_date',
        'duration_minutes',
        'total_marks',
        'passing_marks',
        'type',
        'is_published',
        'created_by',
    ];

    protected $casts = [
        'exam_date' => 'datetime',
        'duration_minutes' => 'integer',
        'total_marks' => 'decimal:2',
        'passing_marks' => 'decimal:2',
        'is_published' => 'boolean',
    ];

    /**
     * Get the subject this exam belongs to.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the class this exam is for.
     */
    public function class(): BelongsTo
    {
        return $this->belongsTo(SchoolClass::class);
    }

    /**
     * Get the academic year this exam belongs to.
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    /**
     * Get the teacher who created this exam.
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Scope to get only published exams.
     */
    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    /**
     * Scope to get exams for a specific teacher.
     */
    public function scopeForTeacher($query, $teacherId)
    {
        return $query->where('created_by', $teacherId);
    }

    /**
     * Get the formatted exam duration.
     */
    public function getFormattedDurationAttribute(): string
    {
        $hours = intval($this->duration_minutes / 60);
        $minutes = $this->duration_minutes % 60;
        
        if ($hours > 0) {
            return $minutes > 0 ? "{$hours}h {$minutes}m" : "{$hours}h";
        }
        
        return "{$minutes}m";
    }
}