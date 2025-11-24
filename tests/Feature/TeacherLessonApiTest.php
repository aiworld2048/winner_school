<?php

namespace Tests\Feature;

use App\Enums\UserType;
use App\Models\Lesson;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TeacherLessonApiTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function teacher_can_list_own_lessons()
    {
        $teacher = User::factory()->create(['type' => UserType::Teacher->value]);
        $class = SchoolClass::factory()->create(['class_teacher_id' => $teacher->id]);
        $subject = Subject::factory()->create(['created_by' => $teacher->id]);

        Lesson::factory()->count(2)->create([
            'teacher_id' => $teacher->id,
            'class_id' => $class->id,
            'subject_id' => $subject->id,
        ]);

        Sanctum::actingAs($teacher);

        $response = $this->getJson('/api/teacher/lessons');

        $response->assertOk()->assertJsonStructure(['data']);
    }
}

