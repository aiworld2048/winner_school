<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class VideoLessonResource extends JsonResource
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
            'video_url' => $this->video_url,
            'thumbnail_url' => $this->thumbnail_url,
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
            'academic_year' => $this->academicYear ? [
                'id' => $this->academicYear->id,
                'name' => $this->academicYear->name,
            ] : null,
            'teacher' => [
                'id' => $this->teacher->id,
                'name' => $this->teacher->name,
            ],
            'lesson_date' => $this->lesson_date ? $this->lesson_date->toIso8601String() : null,
            'duration_minutes' => $this->duration_minutes,
            'formatted_duration' => $this->formatted_duration,
            'status' => $this->status,
            'attachments' => $attachments,
            'views_count' => $this->when(isset($this->views_count), $this->views_count),
            'created_at' => $this->created_at->toIso8601String(),
            'updated_at' => $this->updated_at->toIso8601String(),
        ];
    }
}
