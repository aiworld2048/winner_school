<?php

namespace Database\Seeders;

use App\Models\AcademicYear;
use App\Models\SchoolClass;
use App\Models\User;
use Illuminate\Database\Seeder;

class ClassesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $creatorId = User::query()->orderBy('id')->value('id');
        $academicYearId = AcademicYear::query()
                ->where('is_active', true)
                ->orderBy('start_date')
                ->value('id')
            ?? AcademicYear::query()->orderBy('start_date')->value('id');

        if (!$creatorId || !$academicYearId) {
            $this->command?->warn('ClassesTableSeeder skipped: missing prerequisite users or academic years.');
            return;
        }

        $grades = $this->gradeDefinitions();

        foreach ($grades as $grade) {
            $code = $this->buildCode($grade['label']);

            SchoolClass::updateOrCreate(
                ['code' => $code],
                [
                    'name' => $grade['label'],
                    'grade_level' => $grade['level'],
                    'section' => null,
                    'capacity' => 30,
                    'is_active' => true,
                    'academic_year_id' => $academicYearId,
                    'class_teacher_id' => null,
                    'created_by' => $creatorId,
                ]
            );
        }
    }

    private function gradeDefinitions(): array
    {
        $grades = [
            ['label' => 'KG', 'level' => 0],
        ];

        for ($level = 1; $level <= 12; $level++) {
            $grades[] = [
                'label' => sprintf('G-%d', $level),
                'level' => $level,
            ];
        }

        return $grades;
    }

    private function buildCode(string $label): string
    {
        return strtoupper(str_replace('-', '', $label));
    }
}

