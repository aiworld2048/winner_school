@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">My Lessons</h1>
        <a href="{{ route('teacher.lessons.create') }}" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Lesson
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
                                <th>Title</th>
                                <th>Class</th>
                                <th>Subject</th>
                                <th>Date</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($lessons as $lesson)
                                <tr>
                                    <td>{{ $lesson->title }}</td>
                                    <td>{{ optional($lesson->class)->name }}</td>
                                    <td>{{ optional($lesson->subject)->name }}</td>
                                    <td>{{ $lesson->lesson_date?->format('Y-m-d') }}</td>
                                    <td class="text-right">
                                        <a href="{{ route('teacher.lessons.show', $lesson) }}" class="btn btn-sm btn-outline-secondary">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="{{ route('teacher.lessons.edit', $lesson) }}" class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5" class="text-center py-4">No lessons yet.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer">
                {{ $lessons->links() }}
            </div>
        </div>
    </div>
</section>
@endsection

