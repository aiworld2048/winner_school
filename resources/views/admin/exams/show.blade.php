@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Exam Details</h1>
        <div>
            <a href="{{ route('admin.exams.edit', $exam) }}" class="btn btn-primary">
                <i class="fas fa-edit"></i> Edit
            </a>
            <a href="{{ route('admin.exams.index') }}" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back
            </a>
        </div>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">{{ $exam->title }}</h3>
                    </div>
                    <div class="card-body">
                        <table class="table table-bordered">
                            <tr>
                                <th width="30%">Code</th>
                                <td><code>{{ $exam->code }}</code></td>
                            </tr>
                            <tr>
                                <th>Subject</th>
                                <td>{{ $exam->subject->name }}</td>
                            </tr>
                            <tr>
                                <th>Class</th>
                                <td>{{ $exam->class->name }}</td>
                            </tr>
                            <tr>
                                <th>Academic Year</th>
                                <td>{{ $exam->academicYear->name }}</td>
                            </tr>
                            <tr>
                                <th>Exam Type</th>
                                <td><span class="badge badge-info">{{ ucfirst($exam->type) }}</span></td>
                            </tr>
                            <tr>
                                <th>Exam Date & Time</th>
                                <td>{{ $exam->exam_date->format('F d, Y h:i A') }}</td>
                            </tr>
                            <tr>
                                <th>Duration</th>
                                <td>{{ $exam->formatted_duration }}</td>
                            </tr>
                            <tr>
                                <th>Total Marks</th>
                                <td>{{ number_format($exam->total_marks, 2) }}</td>
                            </tr>
                            <tr>
                                <th>Passing Marks</th>
                                <td>{{ number_format($exam->passing_marks, 2) }}</td>
                            </tr>
                            <tr>
                                <th>Status</th>
                                <td>
                                    <span class="badge {{ $exam->is_published ? 'badge-success' : 'badge-secondary' }}">
                                        {{ $exam->is_published ? 'Published' : 'Draft' }}
                                    </span>
                                </td>
                            </tr>
                            @if($exam->description)
                            <tr>
                                <th>Description</th>
                                <td>
                                    <div class="tex2jax_process">
                                        {!! $exam->description !!}
                                    </div>
                                </td>
                            </tr>
                            @endif
                            <tr>
                                <th>Created By</th>
                                <td>{{ $exam->creator->name ?? 'N/A' }}</td>
                            </tr>
                            <tr>
                                <th>Created At</th>
                                <td>{{ $exam->created_at->format('F d, Y h:i A') }}</td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Quick Actions</h3>
                    </div>
                    <div class="card-body">
                        <a href="{{ route('admin.exams.questions.index', $exam) }}" class="btn btn-info btn-block mb-2">
                            <i class="fas fa-question-circle"></i> Manage Questions
                        </a>
                        <a href="{{ route('admin.exams.edit', $exam) }}" class="btn btn-primary btn-block mb-2">
                            <i class="fas fa-edit"></i> Edit Exam
                        </a>
                        <form action="{{ route('admin.exams.destroy', $exam) }}" method="POST" 
                              onsubmit="return confirm('Are you sure you want to delete this exam?');">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger btn-block">
                                <i class="fas fa-trash"></i> Delete Exam
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

@section('script')
<!-- MathJax for math rendering -->
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
<script>
    window.MathJax = {
        tex: {
            inlineMath: [['\\(', '\\)']],
            displayMath: [['\\[', '\\]']],
            processEscapes: true,
            processEnvironments: true
        },
        options: {
            ignoreHtmlClass: 'tex2jax_ignore',
            processHtmlClass: 'tex2jax_process'
        }
    };
</script>
@endsection

