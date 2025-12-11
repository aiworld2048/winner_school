<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ExamQuestion extends Model
{
    use HasFactory;

    protected $fillable = [
        'exam_id',
        'question_text',
        'question_description',
        'marks',
        'order',
        'type',
        'correct_answer',
    ];

    protected $casts = [
        'marks' => 'decimal:2',
        'order' => 'integer',
        'type' => 'string',
    ];

    /**
     * Get the exam this question belongs to.
     */
    public function exam(): BelongsTo
    {
        return $this->belongsTo(Exam::class);
    }

    /**
     * Get all options for this question.
     */
    public function options(): HasMany
    {
        return $this->hasMany(ExamQuestionOption::class)->orderBy('order');
    }

    /**
     * Get the correct option(s) for this question.
     */
    public function correctOptions(): HasMany
    {
        return $this->hasMany(ExamQuestionOption::class)->where('is_correct', true);
    }

    /**
     * Scope to order questions by order field.
     */
    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }
}

