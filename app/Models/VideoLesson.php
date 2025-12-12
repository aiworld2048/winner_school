<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class VideoLesson extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'video_url',
        'thumbnail_url',
        'class_id',
        'subject_id',
        'teacher_id',
        'academic_year_id',
        'lesson_date',
        'duration_minutes',
        'status',
        'attachments',
        'views_count',
    ];

    protected $casts = [
        'lesson_date' => 'date',
        'duration_minutes' => 'integer',
        'views_count' => 'integer',
        'attachments' => 'array',
    ];

    /**
     * Get the class this video lesson belongs to.
     */
    public function class(): BelongsTo
    {
        return $this->belongsTo(SchoolClass::class, 'class_id');
    }

    /**
     * Get the subject this video lesson is for.
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    /**
     * Get the teacher who created this video lesson.
     */
    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    /**
     * Get the academic year this video lesson belongs to.
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    /**
     * Get the views for this video lesson.
     */
    public function views(): HasMany
    {
        return $this->hasMany(VideoLessonView::class);
    }

    /**
     * Scope to get only published video lessons.
     */
    public function scopePublished($query)
    {
        return $query->where('status', 'published');
    }

    /**
     * Scope to get video lessons for a specific teacher.
     */
    public function scopeForTeacher($query, $teacherId)
    {
        return $query->where('teacher_id', $teacherId);
    }

    /**
     * Get formatted duration.
     */
    public function getFormattedDurationAttribute(): string
    {
        if (!$this->duration_minutes) {
            return 'N/A';
        }

        $hours = floor($this->duration_minutes / 60);
        $minutes = $this->duration_minutes % 60;

        if ($hours > 0) {
            return sprintf('%d:%02d', $hours, $minutes);
        }

        return sprintf('%d min', $minutes);
    }
}
