<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DictionaryEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'english_word',
        'myanmar_meaning',
        'example',
    ];
}

