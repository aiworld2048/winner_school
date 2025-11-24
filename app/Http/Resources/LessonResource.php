<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LessonResource extends JsonResource
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
            'description' => $this->description,
            'content' => $this->content,
            'lesson_date' => optional($this->lesson_date)->toDateString(),
            'duration_minutes' => $this->duration_minutes,
            'class' => [
                'id' => $this->class_id,
                'name' => optional($this->class)->name,
            ],
            'subject' => [
                'id' => $this->subject_id,
                'name' => optional($this->subject)->name,
            ],
        ];
    }
}

