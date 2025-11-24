@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h1 class="m-0">{{ $lesson->title }}</h1>
            <p class="mb-0 text-muted">{{ $lesson->lesson_date?->format('F d, Y') }}</p>
        </div>
        <div>
            <a href="{{ route('teacher.lessons.edit', $lesson) }}" class="btn btn-primary mr-2">
                <i class="fas fa-edit"></i> Edit
            </a>
            <a href="{{ route('teacher.lessons.index') }}" class="btn btn-secondary">Back</a>
        </div>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Info</h3>
                    </div>
                    <div class="card-body">
                        <p><strong>Class:</strong> {{ optional($lesson->class)->name }}</p>
                        <p><strong>Subject:</strong> {{ optional($lesson->subject)->name }}</p>
                        <p><strong>Duration:</strong> {{ $lesson->duration_minutes ? $lesson->duration_minutes.' mins' : '-' }}</p>
                    </div>
                </div>
            </div>
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Description</h3>
                    </div>
                    <div class="card-body">
                        {!! nl2br(e($lesson->description)) ?: '<span class="text-muted">No description</span>' !!}
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Content</h3>
            </div>
            <div class="card-body">
                {!! $lesson->content ?: '<span class="text-muted">No content</span>' !!}
            </div>
        </div>
    </div>
</section>
@endsection

