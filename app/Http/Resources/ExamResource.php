<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ExamResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'code' => $this->code,
            'description' => $this->description,
            'pdf_file_url' => $this->pdf_file ? asset('storage/' . $this->pdf_file) : null,
            'subject' => [
                'id' => $this->subject->id,
                'name' => $this->subject->name,
                'code' => $this->subject->code,
            ],
            'class' => [
                'id' => $this->class->id,
                'name' => $this->class->name,
                'code' => $this->class->code,
            ],
            'academic_year' => [
                'id' => $this->academicYear->id,
                'name' => $this->academicYear->name,
            ],
            'exam_date' => $this->exam_date->toIso8601String(),
            'duration_minutes' => $this->duration_minutes,
            'formatted_duration' => $this->formatted_duration,
            'total_marks' => (float) $this->total_marks,
            'passing_marks' => (float) $this->passing_marks,
            'type' => $this->type,
            'is_published' => $this->is_published,
            'questions' => ExamQuestionResource::collection($this->whenLoaded('questions')),
            'questions_count' => $this->when(isset($this->questions_count), $this->questions_count),
            'created_at' => $this->created_at->toIso8601String(),
            'updated_at' => $this->updated_at->toIso8601String(),
        ];
    }
}

