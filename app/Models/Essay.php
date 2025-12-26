<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Essay extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'instructions',
        'subject_id',
        'class_id',
        'academic_year_id',
        'teacher_id',
        'due_date',
        'due_time',
        'word_count_min',
        'word_count_max',
        'total_marks',
        'status',
        'attachments',
        'pdf_file',
    ];

    protected $casts = [
        'due_date' => 'date',
        'due_time' => 'datetime:H:i',
        'word_count_min' => 'integer',
        'word_count_max' => 'integer',
        'total_marks' => 'decimal:2',
        'attachments' => 'array',
    ];

    /**
     * Get the subject this essay belongs to.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the class this essay is for.
     */
    public function class(): BelongsTo
    {
        return $this->belongsTo(SchoolClass::class);
    }

    /**
     * Get the academic year this essay belongs to.
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    /**
     * Get the teacher who created this essay.
     */
    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    /**
     * Get all submissions for this essay.
     */
    public function submissions(): HasMany
    {
        return $this->hasMany(EssaySubmission::class);
    }

    /**
     * Get all views for this essay.
     */
    public function views(): HasMany
    {
        return $this->hasMany(EssayView::class);
    }

    /**
     * Scope to get only published essays.
     */
    public function scopePublished($query)
    {
        return $query->where('status', 'published');
    }

    /**
     * Scope to get essays for a specific teacher.
     */
    public function scopeForTeacher($query, $teacherId)
    {
        return $query->where('teacher_id', $teacherId);
    }

    /**
     * Get the full due date and time.
     */
    public function getDueDateTimeAttribute()
    {
        if ($this->due_time) {
            return $this->due_date->setTimeFromTimeString($this->due_time);
        }
        return $this->due_date->endOfDay();
    }

    /**
     * Check if essay is overdue.
     */
    public function getIsOverdueAttribute(): bool
    {
        return $this->dueDateTime->isPast();
    }
}

