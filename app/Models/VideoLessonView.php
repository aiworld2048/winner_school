<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class VideoLessonView extends Model
{
    use HasFactory;

    protected $fillable = [
        'video_lesson_id',
        'student_id',
        'amount',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    /**
     * Get the video lesson that was viewed.
     */
    public function videoLesson(): BelongsTo
    {
        return $this->belongsTo(VideoLesson::class);
    }

    /**
     * Get the student who viewed the video lesson.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}
