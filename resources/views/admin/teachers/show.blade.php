@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h1 class="m-0">{{ $teacher->name ?? $teacher->user_name }}</h1>
            <p class="mb-0 text-muted">Teacher Details</p>
        </div>
        <a href="{{ route('admin.teachers.index') }}" class="btn btn-secondary">Back to Teachers</a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Profile</h3>
                    </div>
                    <div class="card-body">
                        <p><strong>User Name:</strong> {{ $teacher->user_name }}</p>
                        <p><strong>Name:</strong> {{ $teacher->name ?? '-' }}</p>
                        <p><strong>Phone:</strong> {{ $teacher->phone ?? '-' }}</p>
                        <p><strong>Email:</strong> {{ $teacher->email ?? '-' }}</p>
                        <p><strong>Status:</strong>
                            <span class="badge {{ $teacher->status ? 'badge-success' : 'badge-secondary' }}">
                                {{ $teacher->status ? 'Active' : 'Inactive' }}
                            </span>
                        </p>
                    </div>
                </div>
            </div>

            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Classes</h3>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped mb-0">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Academic Year</th>
                                    <th>Capacity</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($teacher->classesAsTeacher as $class)
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
        </div>

        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Subjects</h3>
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
                                @forelse($teacher->subjects as $subject)
                                    @php
                                        $year = $academicYears[$subject->pivot->academic_year_id ?? null] ?? null;
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

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Students</h3>
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
                                @forelse($students as $student)
                                    <tr>
                                        <td>{{ $student->name }}</td>
                                        <td>{{ $student->user_name }}</td>
                                        <td>{{ optional($student->schoolClass)->name ?? 'Unassigned' }}</td>
                                        <td>{{ $student->created_at?->format('Y-m-d') }}</td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="4" class="text-center py-4">No students assigned.</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

