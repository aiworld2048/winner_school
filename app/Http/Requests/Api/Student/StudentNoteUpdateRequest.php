<?php

namespace App\Http\Requests\Api\Student;

use Illuminate\Foundation\Http\FormRequest;

class StudentNoteUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'string', 'max:150'],
            'content' => ['nullable', 'string'],
            'color_hex' => ['nullable', 'regex:/^#(?:[0-9a-fA-F]{3}){1,2}$/'],
            'is_pinned' => ['sometimes', 'boolean'],
            'tags' => ['sometimes', 'array'],
            'tags.*' => ['string', 'max:30'],
        ];
    }
}


