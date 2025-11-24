@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Classes</h1>
        <a href="{{ route('admin.school-classes.create') }}" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Class
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Grade</th>
                                <th>Academic Year</th>
                                <th>Teacher</th>
                                <th>Capacity</th>
                                <th>Status</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($classes as $class)
                                <tr>
                                    <td>{{ $class->name }}</td>
                                    <td>{{ $class->grade_level }}{{ $class->section ? ' - '.$class->section : '' }}</td>
                                    <td>{{ optional($class->academicYear)->name ?? 'N/A' }}</td>
                                    <td>{{ optional($class->classTeacher)->name ?? optional($class->classTeacher)->user_name ?? 'Unassigned' }}</td>
                                    <td>{{ $class->capacity }}</td>
                                    <td>
                                        <span class="badge {{ $class->is_active ? 'badge-success' : 'badge-secondary' }}">
                                            {{ $class->is_active ? 'Active' : 'Inactive' }}
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <a href="{{ route('admin.school-classes.edit', $class) }}" class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="{{ route('admin.school-classes.teacher.edit', $class) }}" class="btn btn-sm btn-outline-info">
                                            <i class="fas fa-user-tie"></i>
                                        </a>
                                        <form action="{{ route('admin.school-classes.destroy', $class) }}" method="POST" class="d-inline"
                                              onsubmit="return confirm('Delete this class?');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="text-center py-4">No classes found.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer">
                {{ $classes->links() }}
            </div>
        </div>
    </div>
</section>
@endsection

