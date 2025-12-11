@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Exam Questions Management</h1>
        <a href="{{ route('admin.exams.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to Exams
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
                                <th>Exam Title</th>
                                <th>Code</th>
                                <th>Subject</th>
                                <th>Class</th>
                                <th>Questions</th>
                                <th>Total Marks</th>
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
                                        <span class="badge badge-info">{{ $exam->questions_count }} questions</span>
                                    </td>
                                    <td>{{ number_format($exam->total_marks, 2) }}</td>
                                    <td>
                                        <span class="badge {{ $exam->is_published ? 'badge-success' : 'badge-secondary' }}">
                                            {{ $exam->is_published ? 'Published' : 'Draft' }}
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <a href="{{ route('admin.exams.questions.index', $exam) }}" class="btn btn-sm btn-primary">
                                            <i class="fas fa-question-circle"></i> Manage Questions
                                        </a>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="9" class="text-center py-4">No exams found.</td>
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

