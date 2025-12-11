<?php

namespace App\Http\Requests\Api\Teacher;

use Illuminate\Foundation\Http\FormRequest;

class ExamStoreRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $examId = $this->route('exam')?->id;

        return [
            'title' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'max:50', 'unique:exams,code,' . $examId],
            'description' => ['nullable', 'string'],
            'subject_id' => ['required', 'exists:subjects,id'],
            'class_id' => ['required', 'exists:classes,id'],
            'academic_year_id' => ['required', 'exists:academic_years,id'],
            'exam_date' => ['required', 'date'],
            'duration_minutes' => ['required', 'integer', 'min:1', 'max:600'],
            'total_marks' => ['required', 'numeric', 'min:1', 'max:1000'],
            'passing_marks' => ['required', 'numeric', 'min:0'],
            'type' => ['required', 'in:quiz,assignment,midterm,final,project'],
            'is_published' => ['sometimes', 'boolean'],
        ];
    }

    /**
     * Configure the validator instance.
     */
    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            if ($this->has('total_marks') && $this->has('passing_marks')) {
                if ($this->passing_marks > $this->total_marks) {
                    $validator->errors()->add('passing_marks', 'Passing marks cannot be greater than total marks.');
                }
            }
        });
    }
}

