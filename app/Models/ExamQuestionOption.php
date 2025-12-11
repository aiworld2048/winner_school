<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ExamQuestionOption extends Model
{
    use HasFactory;

    protected $fillable = [
        'exam_question_id',
        'option_text',
        'is_correct',
        'order',
    ];

    protected $casts = [
        'is_correct' => 'boolean',
        'order' => 'integer',
    ];

    /**
     * Get the question this option belongs to.
     */
    public function question(): BelongsTo
    {
        return $this->belongsTo(ExamQuestion::class, 'exam_question_id');
    }
}

