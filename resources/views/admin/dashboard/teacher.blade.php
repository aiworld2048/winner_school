@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h1 class="m-0">Teacher Dashboard</h1>
            <span class="text-muted">Welcome back, {{ $teacher->name ?? $teacher->user_name }}</span>
        </div>
        <a href="{{ route('teacher.students.assign.index') }}" class="btn btn-primary">
            <i class="fas fa-users"></i> Manage Student Classes
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="row">
            <div class="col-lg-4 col-12">
                <div class="small-box bg-primary">
                    <div class="inner">
                        <h3>{{ $classes->count() }}</h3>
                        <p>Assigned Classes</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-school"></i>
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-12">
                <div class="small-box bg-info">
                    <div class="inner">
                        <h3>{{ $subjects->count() }}</h3>
                        <p>Subjects</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-book"></i>
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-12">
                <div class="small-box bg-success">
                    <div class="inner">
                        <h3>{{ $studentsCount }}</h3>
                        <p>Students Under You</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-user-graduate"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Your Classes</h3>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped mb-0">
                            <thead>
                                <tr>
                                    <th>Class</th>
                                    <th>Academic Year</th>
                                    <th>Capacity</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($classes as $class)
                                    <tr>
                                        <td>{{ $class->name }}</td>
                                        <td>{{ optional($class->academicYear)->name ?? 'N/A' }}</td>
                                        <td>{{ $class->capacity }}</td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="3" class="text-center py-4">No classes assigned.</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Your Subjects</h3>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped mb-0">
                            <thead>
                                <tr>
                                    <th>Subject</th>
                                    <th>Code</th>
                                    <th>Academic Year</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($subjects as $subject)
                                    @php
                                        $year = $subjectAcademicYears[$subject->pivot->academic_year_id ?? null] ?? null;
                                    @endphp
                                    <tr>
                                        <td>{{ $subject->name }}</td>
                                        <td>{{ $subject->code }}</td>
                                        <td>{{ $year->name ?? 'N/A' }}</td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="3" class="text-center py-4">No subjects assigned.</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Recent Students</h3>
            </div>
            <div class="card-body p-0">
                <table class="table table-striped mb-0">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Username</th>
                            <th>Class</th>
                            <th>Joined</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($recentStudents as $student)
                            <tr>
                                <td>{{ $student->name }}</td>
                                <td>{{ $student->user_name }}</td>
                                <td>{{ optional($student->schoolClass)->name ?? 'Unassigned' }}</td>
                                <td>{{ $student->created_at?->format('Y-m-d') }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" class="text-center py-4">No students yet.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>
@endsection

