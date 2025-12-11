@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Essays</h1>
        <a href="{{ route('admin.essays.create') }}" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Essay
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <!-- Filters -->
        <div class="card mb-3">
            <div class="card-body">
                <form method="GET" action="{{ route('admin.essays.index') }}" class="row g-3">
                    <div class="col-md-3">
                        <label for="academic_year_id" class="form-label">Academic Year</label>
                        <select name="academic_year_id" id="academic_year_id" class="form-control">
                            <option value="">All Years</option>
                            @foreach($academicYears as $year)
                                <option value="{{ $year->id }}" {{ request('academic_year_id') == $year->id ? 'selected' : '' }}>
                                    {{ $year->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="subject_id" class="form-label">Subject</label>
                        <select name="subject_id" id="subject_id" class="form-control">
                            <option value="">All Subjects</option>
                            @foreach($subjects as $subject)
                                <option value="{{ $subject->id }}" {{ request('subject_id') == $subject->id ? 'selected' : '' }}>
                                    {{ $subject->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label for="class_id" class="form-label">Class</label>
                        <select name="class_id" id="class_id" class="form-control">
                            <option value="">All Classes</option>
                            @foreach($classes as $class)
                                <option value="{{ $class->id }}" {{ request('class_id') == $class->id ? 'selected' : '' }}>
                                    {{ $class->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label for="status" class="form-label">Status</label>
                        <select name="status" id="status" class="form-control">
                            <option value="">All</option>
                            <option value="published" {{ request('status') == 'published' ? 'selected' : '' }}>Published</option>
                            <option value="draft" {{ request('status') == 'draft' ? 'selected' : '' }}>Draft</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <div>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-filter"></i> Filter
                            </button>
                            <a href="{{ route('admin.essays.index') }}" class="btn btn-secondary">
                                <i class="fas fa-times"></i> Clear
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Essays List -->
        <div class="card">
            <div class="card-body">
                @if(session('success'))
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        {{ session('success') }}
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                @endif

                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Subject</th>
                                <th>Class</th>
                                <th>Due Date</th>
                                <th>Marks</th>
                                <th>Views</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($essays as $essay)
                                <tr>
                                    <td>
                                        <strong>{{ $essay->title }}</strong>
                                        @if($essay->is_overdue && $essay->status === 'published')
                                            <span class="badge badge-danger ml-2">Overdue</span>
                                        @endif
                                    </td>
                                    <td>{{ $essay->subject->name }}</td>
                                    <td>{{ $essay->class->name }}</td>
                                    <td>
                                        {{ $essay->due_date->format('M d, Y') }}
                                        @if($essay->due_time)
                                            {{ \Carbon\Carbon::parse($essay->due_time)->format('h:i A') }}
                                        @endif
                                    </td>
                                    <td>{{ number_format($essay->total_marks, 0) }}</td>
                                    <td>
                                        <span class="badge badge-info">{{ $essay->views_count ?? 0 }}</span>
                                    </td>
                                    <td>
                                        @if($essay->status === 'published')
                                            <span class="badge badge-success">Published</span>
                                        @else
                                            <span class="badge badge-secondary">Draft</span>
                                        @endif
                                    </td>
                                    <td>
                                        <a href="{{ route('admin.essays.show', $essay) }}" class="btn btn-sm btn-info" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="{{ route('admin.essays.edit', $essay) }}" class="btn btn-sm btn-primary" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <form action="{{ route('admin.essays.destroy', $essay) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this essay?');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-danger" title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="text-center">No essays found.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <div class="mt-3">
                    {{ $essays->links() }}
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

