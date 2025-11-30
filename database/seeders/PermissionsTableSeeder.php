<?php

namespace Database\Seeders;

use App\Models\Admin\Permission;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class PermissionsTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $permissions = [
            // Admin permissions
            [
                'title' => 'admin_access',
                'group' => 'admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'admin_dashboard',
                'group' => 'admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'admin_settings',
                'group' => 'admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'admin_reports',
                'group' => 'admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Teacher management
            [
                'title' => 'teacher_index',
                'group' => 'teacher',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'teacher_create',
                'group' => 'teacher',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'teacher_edit',
                'group' => 'teacher',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'teacher_delete',
                'group' => 'teacher',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'teacher_view',
                'group' => 'teacher',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'teacher_wallet_deposit',
                'group' => 'teacher',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'teacher_wallet_withdraw',
                'group' => 'teacher',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Student management
            [
                'title' => 'student_index',
                'group' => 'student',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'student_create',
                'group' => 'student',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'student_edit',
                'group' => 'student',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'student_delete',
                'group' => 'student',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'student_view',
                'group' => 'student',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'student_assign_teacher',
                'group' => 'student',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Parent management
            [
                'title' => 'parent_index',
                'group' => 'parent',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'parent_create',
                'group' => 'parent',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'parent_edit',
                'group' => 'parent',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'parent_delete',
                'group' => 'parent',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'parent_view',
                'group' => 'parent',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Guardian management
            [
                'title' => 'guardian_index',
                'group' => 'guardian',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'guardian_create',
                'group' => 'guardian',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'guardian_edit',
                'group' => 'guardian',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'guardian_delete',
                'group' => 'guardian',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'guardian_view',
                'group' => 'guardian',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Academic management
            [
                'title' => 'academic_year_manage',
                'group' => 'academic',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'class_manage',
                'group' => 'academic',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'subject_manage',
                'group' => 'academic',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'schedule_manage',
                'group' => 'academic',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'exam_manage',
                'group' => 'academic',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'grade_manage',
                'group' => 'academic',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Lesson management
            [
                'title' => 'lesson_index',
                'group' => 'lesson',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'lesson_create',
                'group' => 'lesson',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'lesson_edit',
                'group' => 'lesson',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'lesson_delete',
                'group' => 'lesson',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'lesson_view',
                'group' => 'lesson',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Attendance management
            [
                'title' => 'attendance_view',
                'group' => 'attendance',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'attendance_mark',
                'group' => 'attendance',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'attendance_edit',
                'group' => 'attendance',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'attendance_report',
                'group' => 'attendance',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Fee management
            [
                'title' => 'fee_view',
                'group' => 'fee',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'fee_collect',
                'group' => 'fee',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'fee_manage',
                'group' => 'fee',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'fee_report',
                'group' => 'fee',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Communication
            [
                'title' => 'message_send',
                'group' => 'communication',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'message_view',
                'group' => 'communication',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'announcement_manage',
                'group' => 'communication',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Reports
            [
                'title' => 'report_student',
                'group' => 'report',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'report_teacher',
                'group' => 'report',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'report_academic',
                'group' => 'report',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'report_financial',
                'group' => 'report',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Profile management
            [
                'title' => 'profile_view',
                'group' => 'profile',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'profile_edit',
                'group' => 'profile',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title' => 'password_change',
                'group' => 'profile',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        Permission::insert($permissions);
    }
}
