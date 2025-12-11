<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ExamQuestionResource extends JsonResource
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
            'question_text' => $this->question_text,
            'question_description' => $this->question_description,
            'marks' => (float) $this->marks,
            'order' => $this->order,
            'type' => $this->type,
            'correct_answer' => $this->correct_answer,
            'options' => ExamQuestionOptionResource::collection($this->whenLoaded('options')),
        ];
    }
}

