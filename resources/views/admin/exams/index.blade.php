@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Exams</h1>
        <a href="{{ route('admin.exams.create') }}" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Exam
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <!-- Filters -->
        <div class="card mb-3">
            <div class="card-body">
                <form method="GET" action="{{ route('admin.exams.index') }}" class="row g-3">
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
                        <label for="type" class="form-label">Type</label>
                        <select name="type" id="type" class="form-control">
                            <option value="">All Types</option>
                            <option value="quiz" {{ request('type') == 'quiz' ? 'selected' : '' }}>Quiz</option>
                            <option value="assignment" {{ request('type') == 'assignment' ? 'selected' : '' }}>Assignment</option>
                            <option value="midterm" {{ request('type') == 'midterm' ? 'selected' : '' }}>Midterm</option>
                            <option value="final" {{ request('type') == 'final' ? 'selected' : '' }}>Final</option>
                            <option value="project" {{ request('type') == 'project' ? 'selected' : '' }}>Project</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label for="is_published" class="form-label">Status</label>
                        <select name="is_published" id="is_published" class="form-control">
                            <option value="">All</option>
                            <option value="1" {{ request('is_published') == '1' ? 'selected' : '' }}>Published</option>
                            <option value="0" {{ request('is_published') == '0' ? 'selected' : '' }}>Draft</option>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-filter"></i> Filter
                        </button>
                        <a href="{{ route('admin.exams.index') }}" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Clear
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Title</th>
                                <th>Code</th>
                                <th>Subject</th>
                                <th>Class</th>
                                <th>Type</th>
                                <th>Exam Date</th>
                                <th>Duration</th>
                                <th>Marks</th>
                                <th>Status</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($exams as $exam)
                                <tr>
                                    <td>{{ $exam->id }}</td>
                                    <td>{{ $exam->title }}</td>
                                    <td><code>{{ $exam->code }}</code></td>
                                    <td>{{ $exam->subject->name }}</td>
                                    <td>{{ $exam->class->name }}</td>
                                    <td>
                                        <span class="badge badge-info">{{ ucfirst($exam->type) }}</span>
                                    </td>
                                    <td>{{ $exam->exam_date->format('M d, Y H:i') }}</td>
                                    <td>{{ $exam->formatted_duration }}</td>
                                    <td>{{ $exam->total_marks }} (Pass: {{ $exam->passing_marks }})</td>
                                    <td>
                                        <span class="badge {{ $exam->is_published ? 'badge-success' : 'badge-secondary' }}">
                                            {{ $exam->is_published ? 'Published' : 'Draft' }}
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <a href="{{ route('admin.exams.show', $exam) }}" class="btn btn-sm btn-outline-secondary" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="{{ route('admin.exams.questions.index', $exam) }}" class="btn btn-sm btn-outline-info" title="Questions">
                                            <i class="fas fa-question-circle"></i>
                                        </a>
                                        <a href="{{ route('admin.exams.edit', $exam) }}" class="btn btn-sm btn-outline-primary" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <form action="{{ route('admin.exams.destroy', $exam) }}" method="POST" class="d-inline"
                                              onsubmit="return confirm('Are you sure you want to delete this exam?');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="11" class="text-center py-4">No exams found.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer">
                {{ $exams->links() }}
            </div>
        </div>
    </div>
</section>
@endsection

