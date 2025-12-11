<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class EssayResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $attachments = [];
        if ($this->attachments) {
            foreach ($this->attachments as $attachment) {
                $attachments[] = [
                    'name' => basename($attachment),
                    'url' => Storage::url($attachment),
                ];
            }
        }

        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'instructions' => $this->instructions,
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
            'teacher' => [
                'id' => $this->teacher->id,
                'name' => $this->teacher->name,
            ],
            'due_date' => $this->due_date->toIso8601String(),
            'due_time' => $this->due_time ? \Carbon\Carbon::parse($this->due_time)->format('H:i') : null,
            'due_date_time' => $this->dueDateTime->toIso8601String(),
            'word_count_min' => $this->word_count_min,
            'word_count_max' => $this->word_count_max,
            'total_marks' => (float) $this->total_marks,
            'status' => $this->status,
            'is_overdue' => $this->is_overdue,
            'attachments' => $attachments,
            'submissions_count' => $this->when(isset($this->submissions_count), $this->submissions_count),
            'views_count' => $this->when(isset($this->views_count), $this->views_count),
            'created_at' => $this->created_at->toIso8601String(),
            'updated_at' => $this->updated_at->toIso8601String(),
        ];
    }
}

