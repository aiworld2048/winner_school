<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
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
        return [
            'name' => ['required', 'string', 'min:3'],
            'password' => 'required|min:6',
            'phone' => ['required', 'regex:/^[0-9]+$/', 'unique:users,phone'],
            // 'referral_code' => ['required'],
            'class_id' => ['nullable', 'exists:classes,id'],
            'subject_id' => ['nullable', 'exists:subjects,id'],
            'academic_year_id' => ['nullable', 'exists:academic_years,id'],
            'referral_code' => ['nullable', 'string', 'max:255'],
        ];
    }
}
