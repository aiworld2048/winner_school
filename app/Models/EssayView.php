<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EssayView extends Model
{
    use HasFactory;

    protected $fillable = [
        'essay_id',
        'student_id',
        'amount',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    /**
     * Get the essay this view belongs to.
     */
    public function essay(): BelongsTo
    {
        return $this->belongsTo(Essay::class);
    }

    /**
     * Get the student who viewed this essay.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}

