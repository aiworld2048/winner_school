@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Video Lesson Details</h1>
        <div>
            <a href="{{ route('admin.video-lessons.edit', $videoLesson) }}" class="btn btn-primary">
                <i class="fas fa-edit"></i> Edit
            </a>
            <a href="{{ route('admin.video-lessons.index') }}" class="btn btn-secondary">
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
                        <h3 class="card-title">{{ $videoLesson->title }}</h3>
                    </div>
                    <div class="card-body">
                        @if($videoLesson->thumbnail_url)
                            <div class="mb-3">
                                <img src="{{ $videoLesson->thumbnail_url }}" alt="Video Thumbnail" class="img-fluid rounded" style="max-height: 300px;">
                            </div>
                        @endif

                        @if($videoLesson->description)
                            <div class="mb-3">
                                <h5>Description</h5>
                                <p>{{ $videoLesson->description }}</p>
                            </div>
                        @endif

                        <div class="mb-3">
                            <h5>Video</h5>
                            <a href="{{ $videoLesson->video_url }}" target="_blank" class="btn btn-primary">
                                <i class="fas fa-play"></i> Watch Video
                            </a>
                            <small class="d-block text-muted mt-2">{{ $videoLesson->video_url }}</small>
                        </div>

                        @if($videoLesson->attachments && count($videoLesson->attachments) > 0)
                            <div class="mb-3">
                                <h5>Attachments</h5>
                                <ul class="list-unstyled">
                                    @foreach($videoLesson->attachments as $attachment)
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
                                <td>{{ $videoLesson->subject->name }}</td>
                            </tr>
                            <tr>
                                <th>Class:</th>
                                <td>{{ $videoLesson->class->name }}</td>
                            </tr>
                            @if($videoLesson->academicYear)
                                <tr>
                                    <th>Academic Year:</th>
                                    <td>{{ $videoLesson->academicYear->name }}</td>
                                </tr>
                            @endif
                            <tr>
                                <th>Teacher:</th>
                                <td>{{ $videoLesson->teacher->name }}</td>
                            </tr>
                            <tr>
                                <th>Lesson Date:</th>
                                <td>
                                    @if($videoLesson->lesson_date)
                                        {{ $videoLesson->lesson_date->format('M d, Y') }}
                                    @else
                                        <span class="text-muted">N/A</span>
                                    @endif
                                </td>
                            </tr>
                            <tr>
                                <th>Duration:</th>
                                <td>{{ $videoLesson->formatted_duration }}</td>
                            </tr>
                            <tr>
                                <th>Status:</th>
                                <td>
                                    @if($videoLesson->status === 'published')
                                        <span class="badge badge-success">Published</span>
                                    @else
                                        <span class="badge badge-secondary">Draft</span>
                                    @endif
                                </td>
                            </tr>
                            <tr>
                                <th>Views:</th>
                                <td>{{ $videoLesson->views_count ?? 0 }}</td>
                            </tr>
                            <tr>
                                <th>Created:</th>
                                <td>{{ $videoLesson->created_at->format('M d, Y h:i A') }}</td>
                            </tr>
                            <tr>
                                <th>Updated:</th>
                                <td>{{ $videoLesson->updated_at->format('M d, Y h:i A') }}</td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

