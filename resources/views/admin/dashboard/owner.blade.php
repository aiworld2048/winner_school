@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1 class="m-0">School Dashboard</h1>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="#">Home</a></li>
                    <li class="breadcrumb-item active">Dashboard</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <!-- Key Metrics -->
        <div class="row">
            <div class="col-lg-3 col-6">
                <div class="small-box bg-info">
                    <div class="inner">
                        <h3>{{ $totalClasses }}</h3>
                        <p>Total Classes</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-school"></i>
                    </div>
                </div>
            </div>

            <div class="col-lg-3 col-6">
                <div class="small-box bg-primary">
                    <div class="inner">
                        <h3>{{ $totalAcademicYears }}</h3>
                        <p>Academic Years</p>
                        <p class="mb-0 text-sm">
                            Current: {{ $currentAcademicYear->name ?? 'Not set' }}
                        </p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                </div>
            </div>

            <div class="col-lg-3 col-6">
                <div class="small-box bg-success">
                    <div class="inner">
                        <h3>{{ $totalStudents }}</h3>
                        <p>Total Students</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-user-graduate"></i>
                    </div>
                </div>
            </div>

            <div class="col-lg-3 col-6">
                <div class="small-box bg-secondary">
                    <div class="inner">
                        <h3>{{ $totalTeachers }}</h3>
                        <p>Total Teachers</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-chalkboard-teacher"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-3 col-6">
                <div class="small-box bg-warning">
                    <div class="inner">
                        <h3>{{ $totalSubjects }}</h3>
                        <p>Total Subjects</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-book"></i>
                    </div>
                </div>
            </div>

            <div class="col-lg-9 col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Current Academic Year</h3>
                    </div>
                    <div class="card-body">
                        @if($currentAcademicYear)
                            <div class="row">
                                <div class="col-md-6">
                                    <p class="mb-1"><strong>Name:</strong> {{ $currentAcademicYear->name }}</p>
                                    <p class="mb-1"><strong>Code:</strong> {{ $currentAcademicYear->code }}</p>
                                </div>
                                <div class="col-md-6">
                                    <p class="mb-1">
                                        <strong>Start Date:</strong>
                                        {{ optional($currentAcademicYear->start_date)->format('M d, Y') }}
                                    </p>
                                    <p class="mb-0">
                                        <strong>End Date:</strong>
                                        {{ optional($currentAcademicYear->end_date)->format('M d, Y') }}
                                    </p>
                                </div>
                            </div>
                        @else
                            <p class="mb-0 text-muted">No academic year configured yet.</p>
                        @endif
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Activity -->
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Recent Students</h3>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped mb-0">
                            <thead>
                                <tr>
                                    <th>Student ID</th>
                                    <th>Name</th>
                                    <th>Class</th>
                                    <th>Joined</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($recentStudents as $student)
                                    <tr>
                                        <td>{{ $student->user_name }}</td>
                                        <td>{{ $student->name }}</td>
                                        <td>{{ optional($student->schoolClass)->name ?? 'Unassigned' }}</td>
                                        <td>{{ $student->created_at?->format('Y-m-d') }}</td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="4" class="text-center">No students yet</td>
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
                        <h3 class="card-title">Recent Classes</h3>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped mb-0">
                            <thead>
                                <tr>
                                    <th>Class</th>
                                    <th>Academic Year</th>
                                    <th>Teacher</th>
                                    <th>Capacity</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($recentClasses as $class)
                                    <tr>
                                        <td>{{ $class->name }}</td>
                                        <td>{{ optional($class->academicYear)->name ?? 'N/A' }}</td>
                                        <td>{{ optional($class->classTeacher)->name ?? 'Unassigned' }}</td>
                                        <td>{{ $class->capacity }}</td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="4" class="text-center">No classes yet</td>
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
