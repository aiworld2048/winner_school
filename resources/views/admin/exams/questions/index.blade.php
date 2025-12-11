@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h1 class="m-0">Exam Questions</h1>
            <p class="mb-0 text-muted">{{ $exam->title }} ({{ $exam->code }})</p>
        </div>
        <div>
            <a href="{{ route('admin.exams.show', $exam) }}" class="btn btn-secondary mr-2">
                <i class="fas fa-arrow-left"></i> Back to Exam
            </a>
            <a href="{{ route('admin.exams.questions.create', $exam) }}" class="btn btn-primary">
                <i class="fas fa-plus"></i> Add Question
            </a>
        </div>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Questions ({{ $questions->count() }})</h3>
                <div class="card-tools">
                    <span class="badge badge-info">Total Marks: {{ number_format($totalQuestionMarks, 2) }} / {{ number_format($exam->total_marks, 2) }}</span>
                </div>
            </div>
            <div class="card-body">
                @if($questions->isEmpty())
                    <div class="alert alert-info text-center">
                        <i class="fas fa-info-circle"></i> No questions added yet. 
                        <a href="{{ route('admin.exams.questions.create', $exam) }}" class="alert-link">Add your first question</a>
                    </div>
                @else
                    <div class="questions-list">
                        @foreach($questions as $index => $question)
                            <div class="card mb-3">
                                <div class="card-header bg-light">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <strong>Question #{{ $question->order }}</strong>
                                            <span class="badge badge-primary ml-2">{{ ucfirst(str_replace('_', ' ', $question->type)) }}</span>
                                            <span class="badge badge-success ml-2">{{ number_format($question->marks, 2) }} marks</span>
                                        </div>
                                        <div>
                                            <a href="{{ route('admin.exams.questions.edit', [$exam, $question]) }}" class="btn btn-sm btn-primary">
                                                <i class="fas fa-edit"></i> Edit
                                            </a>
                                            <form action="{{ route('admin.exams.questions.destroy', [$exam, $question]) }}" method="POST" class="d-inline"
                                                  onsubmit="return confirm('Are you sure you want to delete this question?');">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="btn btn-sm btn-danger">
                                                    <i class="fas fa-trash"></i> Delete
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="question-text mb-3">
                                        <strong>{{ $question->question_text }}</strong>
                                        @if($question->question_description)
                                            <div class="mt-2 tex2jax_process">
                                                {!! $question->question_description !!}
                                            </div>
                                        @endif
                                    </div>

                                    @if($question->type === 'multiple_choice' || $question->type === 'true_false')
                                        <div class="options-list">
                                            <strong>Options:</strong>
                                            <ul class="list-group mt-2">
                                                @foreach($question->options as $option)
                                                    <li class="list-group-item d-flex justify-content-between align-items-center">
                                                        <span>
                                                            {{ $option->option_text }}
                                                            @if($option->is_correct)
                                                                <span class="badge badge-success ml-2">
                                                                    <i class="fas fa-check"></i> Correct
                                                                </span>
                                                            @endif
                                                        </span>
                                                        <span class="badge badge-secondary">{{ $option->order }}</span>
                                                    </li>
                                                @endforeach
                                            </ul>
                                        </div>
                                    @elseif($question->type === 'short_answer')
                                        <div class="correct-answer">
                                            <strong>Correct Answer:</strong>
                                            <p class="mb-0 mt-1">{{ $question->correct_answer }}</p>
                                        </div>
                                    @endif
                                </div>
                            </div>
                        @endforeach
                    </div>
                @endif
            </div>
        </div>
    </div>
</section>
@endsection

@section('script')
<!-- MathJax for math rendering -->
<script src="{{ asset('js/polyfill.min.js') }}"></script>
<script src="{{ asset('js/mathjax.js') }}"></script>
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

