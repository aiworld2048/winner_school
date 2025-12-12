@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Edit Video Lesson</h1>
        <a href="{{ route('admin.video-lessons.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.video-lessons.update', $videoLesson) }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    @method('PUT')
                    
                    <div class="row">
                        <div class="col-md-8">
                            <div class="form-group">
                                <label for="title">Title <span class="text-danger">*</span></label>
                                <input type="text" class="form-control @error('title') is-invalid @enderror" 
                                       id="title" name="title" value="{{ old('title', $videoLesson->title) }}" required>
                                @error('title')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="description">Description</label>
                                <textarea class="form-control @error('description') is-invalid @enderror" 
                                          id="description" name="description" rows="3">{{ old('description', $videoLesson->description) }}</textarea>
                                @error('description')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="video_url">Video URL <span class="text-danger">*</span></label>
                                <input type="url" class="form-control @error('video_url') is-invalid @enderror" 
                                       id="video_url" name="video_url" value="{{ old('video_url', $videoLesson->video_url) }}" 
                                       placeholder="https://www.youtube.com/watch?v=..." required>
                                <small class="form-text text-muted">Enter YouTube, Vimeo, or direct video URL.</small>
                                @error('video_url')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="thumbnail_url">Thumbnail URL</label>
                                <input type="url" class="form-control @error('thumbnail_url') is-invalid @enderror" 
                                       id="thumbnail_url" name="thumbnail_url" value="{{ old('thumbnail_url', $videoLesson->thumbnail_url) }}" 
                                       placeholder="https://example.com/thumbnail.jpg">
                                <small class="form-text text-muted">Optional: URL to a thumbnail image for the video.</small>
                                @error('thumbnail_url')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="col-md-4">
                            <div class="form-group">
                                <label for="subject_id">Subject <span class="text-danger">*</span></label>
                                <select class="form-control @error('subject_id') is-invalid @enderror" 
                                        id="subject_id" name="subject_id" required>
                                    <option value="">Select Subject</option>
                                    @foreach($subjects as $subject)
                                        <option value="{{ $subject->id }}" {{ old('subject_id', $videoLesson->subject_id) == $subject->id ? 'selected' : '' }}>
                                            {{ $subject->name }}
                                        </option>
                                    @endforeach
                                </select>
                                @error('subject_id')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="class_id">Class <span class="text-danger">*</span></label>
                                <select class="form-control @error('class_id') is-invalid @enderror" 
                                        id="class_id" name="class_id" required>
                                    <option value="">Select Class</option>
                                    @foreach($classes as $class)
                                        <option value="{{ $class->id }}" {{ old('class_id', $videoLesson->class_id) == $class->id ? 'selected' : '' }}>
                                            {{ $class->name }}
                                        </option>
                                    @endforeach
                                </select>
                                @error('class_id')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="academic_year_id">Academic Year</label>
                                <select class="form-control @error('academic_year_id') is-invalid @enderror" 
                                        id="academic_year_id" name="academic_year_id">
                                    <option value="">Select Academic Year</option>
                                    @foreach($academicYears as $year)
                                        <option value="{{ $year->id }}" {{ old('academic_year_id', $videoLesson->academic_year_id) == $year->id ? 'selected' : '' }}>
                                            {{ $year->name }}
                                        </option>
                                    @endforeach
                                </select>
                                @error('academic_year_id')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="lesson_date">Lesson Date</label>
                                <input type="date" class="form-control @error('lesson_date') is-invalid @enderror" 
                                       id="lesson_date" name="lesson_date" value="{{ old('lesson_date', $videoLesson->lesson_date ? $videoLesson->lesson_date->format('Y-m-d') : '') }}">
                                @error('lesson_date')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="duration_minutes">Duration (minutes)</label>
                                <input type="number" class="form-control @error('duration_minutes') is-invalid @enderror" 
                                       id="duration_minutes" name="duration_minutes" value="{{ old('duration_minutes', $videoLesson->duration_minutes) }}" 
                                       min="1" placeholder="e.g., 30">
                                @error('duration_minutes')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="status">Status <span class="text-danger">*</span></label>
                                <select class="form-control @error('status') is-invalid @enderror" 
                                        id="status" name="status" required>
                                    <option value="draft" {{ old('status', $videoLesson->status) == 'draft' ? 'selected' : '' }}>Draft</option>
                                    <option value="published" {{ old('status', $videoLesson->status) == 'published' ? 'selected' : '' }}>Published</option>
                                </select>
                                @error('status')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="attachments">Add More Attachments</label>
                                <input type="file" class="form-control-file @error('attachments') is-invalid @enderror" 
                                       id="attachments" name="attachments[]" multiple>
                                <small class="form-text text-muted">You can upload multiple files (max 10MB each).</small>
                                @error('attachments')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                                @if($videoLesson->attachments && count($videoLesson->attachments) > 0)
                                    <div class="mt-2">
                                        <small class="text-muted">Current attachments:</small>
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

                    <div class="form-group mt-3">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Update Video Lesson
                        </button>
                        <a href="{{ route('admin.video-lessons.index') }}" class="btn btn-secondary">
                            Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

