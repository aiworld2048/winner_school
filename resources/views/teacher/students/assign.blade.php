@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">My Students</h1>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body p-0">
                <div class="px-3 py-2">
                    <a href="{{ route('teacher.students.assign.create') }}" class="btn btn-primary">
                        <i class="fas fa-user-plus"></i> New Student
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Username</th>
                                <th>Current Class</th>
                                <th>Assign to Class</th>
                                <th class="text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($students as $student)
                                <tr>
                                    <td>{{ $student->name }}</td>
                                    <td>{{ $student->user_name }}</td>
                                    <td>{{ optional($student->schoolClass)->name ?? 'Unassigned' }}</td>
                                    <td>
                                        <form action="{{ route('teacher.students.assign.update', $student) }}" method="POST" class="form-inline">
                                            @csrf
                                            @method('PUT')
                                            <select name="class_id" class="form-control mr-2">
                                                <option value="">Unassigned</option>
                                                @foreach($classes as $class)
                                                    <option value="{{ $class->id }}" {{ $student->class_id == $class->id ? 'selected' : '' }}>
                                                        {{ $class->name }}
                                                    </option>
                                                @endforeach
                                            </select>
                                            <button type="submit" class="btn btn-primary btn-sm">Save</button>
                                        </form>
                                    </td>
                                    <td class="text-right">
                                        <span class="text-muted">{{ $student->created_at?->format('Y-m-d') }}</span>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5" class="text-center py-4">No students assigned to you.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer">
                {{ $students->links() }}
            </div>
        </div>
    </div>
</section>
@endsection

