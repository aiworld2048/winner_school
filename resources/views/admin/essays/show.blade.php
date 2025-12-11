@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Essay Details</h1>
        <div>
            <a href="{{ route('admin.essays.edit', $essay) }}" class="btn btn-primary">
                <i class="fas fa-edit"></i> Edit
            </a>
            <a href="{{ route('admin.essays.index') }}" class="btn btn-secondary">
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
                        <h3 class="card-title">{{ $essay->title }}</h3>
                    </div>
                    <div class="card-body">
                        @if($essay->description)
                            <div class="mb-3">
                                <h5>Description</h5>
                                <p>{{ $essay->description }}</p>
                            </div>
                        @endif

                        @if($essay->instructions)
                            <div class="mb-3">
                                <h5>Instructions</h5>
                                <div class="border p-3 bg-light">
                                    {!! nl2br(e($essay->instructions)) !!}
                                </div>
                            </div>
                        @endif

                        @if($essay->attachments && count($essay->attachments) > 0)
                            <div class="mb-3">
                                <h5>Attachments</h5>
                                <ul class="list-unstyled">
                                    @foreach($essay->attachments as $attachment)
                                        <li>
                                            <i class="fas fa-file"></i> 
                                            <a href="{{ Storage::url($attachment) }}" target="_blank">{{ basename($attachment) }}</a>
                                        </li>
                                    @endforeach
                                </ul>
                            </div>
                        @endif
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Details</h3>
                    </div>
                    <div class="card-body">
                        <table class="table table-sm">
                            <tr>
                                <th>Subject:</th>
                                <td>{{ $essay->subject->name }}</td>
                            </tr>
                            <tr>
                                <th>Class:</th>
                                <td>{{ $essay->class->name }}</td>
                            </tr>
                            <tr>
                                <th>Academic Year:</th>
                                <td>{{ $essay->academicYear->name }}</td>
                            </tr>
                            <tr>
                                <th>Teacher:</th>
                                <td>{{ $essay->teacher->name }}</td>
                            </tr>
                            <tr>
                                <th>Due Date:</th>
                                <td>
                                    {{ $essay->due_date->format('M d, Y') }}
                                    @if($essay->due_time)
                                        {{ \Carbon\Carbon::parse($essay->due_time)->format('h:i A') }}
                                    @endif
                                    @if($essay->is_overdue)
                                        <span class="badge badge-danger ml-2">Overdue</span>
                                    @endif
                                </td>
                            </tr>
                            <tr>
                                <th>Total Marks:</th>
                                <td>{{ number_format($essay->total_marks, 0) }}</td>
                            </tr>
                            @if($essay->word_count_min || $essay->word_count_max)
                                <tr>
                                    <th>Word Count:</th>
                                    <td>
                                        @if($essay->word_count_min && $essay->word_count_max)
                                            {{ $essay->word_count_min }} - {{ $essay->word_count_max }} words
                                        @elseif($essay->word_count_min)
                                            Minimum: {{ $essay->word_count_min }} words
                                        @elseif($essay->word_count_max)
                                            Maximum: {{ $essay->word_count_max }} words
                                        @endif
                                    </td>
                                </tr>
                            @endif
                            <tr>
                                <th>Status:</th>
                                <td>
                                    @if($essay->status === 'published')
                                        <span class="badge badge-success">Published</span>
                                    @else
                                        <span class="badge badge-secondary">Draft</span>
                                    @endif
                                </td>
                            </tr>
                            <tr>
                                <th>Submissions:</th>
                                <td>{{ $essay->submissions->count() }}</td>
                            </tr>
                            <tr>
                                <th>Views:</th>
                                <td>{{ $essay->views_count ?? 0 }}</td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

