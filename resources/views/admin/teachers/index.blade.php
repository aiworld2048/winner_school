@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Teachers</h1>
        <a href="{{ route('admin.teachers.create') }}" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Teacher
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
                                <th>#</th>
                                <th>User Name</th>
                                <th>Name</th>
                                <th>Phone</th>
                                <th>Classes</th>
                                <th>Subjects</th>
                                <th>Status</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse ($teachers as $teacher)
                                <tr>
                                    <td>{{ $teacher->id }}</td>
                                    <td>{{ $teacher->user_name }}</td>
                                    <td>{{ $teacher->name }}</td>
                                    <td>{{ $teacher->phone ?? '-' }}</td>
                                    <td>{{ $teacher->classes_count }}</td>
                                    <td>{{ $teacher->subjects_count }}</td>
                                    <td>
                                        <span class="badge {{ $teacher->status ? 'badge-success' : 'badge-secondary' }}">
                                            {{ $teacher->status ? 'Active' : 'Inactive' }}
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <a href="{{ route('admin.teachers.show', $teacher) }}" class="btn btn-sm btn-outline-secondary">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="{{ route('admin.teachers.edit', $teacher) }}" class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="{{ route('admin.teachers.subjects.create', $teacher) }}" class="btn btn-sm btn-outline-info">
                                            <i class="fas fa-book-open"></i>
                                        </a>
                                        <form action="{{ route('admin.teachers.destroy', $teacher) }}" method="POST" class="d-inline"
                                              onsubmit="return confirm('Are you sure you want to delete this teacher?');">
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
                                    <td colspan="7" class="text-center py-4">No teachers found.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer">
                {{ $teachers->links() }}
            </div>
        </div>
    </div>
</section>
@endsection

