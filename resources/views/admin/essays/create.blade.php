@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Create Essay</h1>
        <a href="{{ route('admin.essays.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.essays.store') }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    
                    <div class="row">
                        <div class="col-md-8">
                            <div class="form-group">
                                <label for="title">Title <span class="text-danger">*</span></label>
                                <input type="text" class="form-control @error('title') is-invalid @enderror" 
                                       id="title" name="title" value="{{ old('title') }}" required>
                                @error('title')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="description">Description</label>
                                <textarea class="form-control @error('description') is-invalid @enderror" 
                                          id="description" name="description" rows="3">{{ old('description') }}</textarea>
                                @error('description')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="instructions">Instructions</label>
                                <textarea class="form-control @error('instructions') is-invalid @enderror" 
                                          id="instructions" name="instructions" rows="6">{{ old('instructions') }}</textarea>
                                <small class="form-text text-muted">Provide detailed instructions for students on how to complete this essay.</small>
                                @error('instructions')
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
                                        <option value="{{ $subject->id }}" {{ old('subject_id') == $subject->id ? 'selected' : '' }}>
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
                                        <option value="{{ $class->id }}" {{ old('class_id') == $class->id ? 'selected' : '' }}>
                                            {{ $class->name }}
                                        </option>
                                    @endforeach
                                </select>
                                @error('class_id')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="academic_year_id">Academic Year <span class="text-danger">*</span></label>
                                <select class="form-control @error('academic_year_id') is-invalid @enderror" 
                                        id="academic_year_id" name="academic_year_id" required>
                                    <option value="">Select Academic Year</option>
                                    @foreach($academicYears as $year)
                                        <option value="{{ $year->id }}" {{ old('academic_year_id') == $year->id ? 'selected' : '' }}>
                                            {{ $year->name }}
                                        </option>
                                    @endforeach
                                </select>
                                @error('academic_year_id')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="due_date">Due Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control @error('due_date') is-invalid @enderror" 
                                       id="due_date" name="due_date" value="{{ old('due_date', date('Y-m-d')) }}" required>
                                @error('due_date')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="due_time">Due Time</label>
                                <input type="time" class="form-control @error('due_time') is-invalid @enderror" 
                                       id="due_time" name="due_time" value="{{ old('due_time') }}">
                                @error('due_time')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="total_marks">Total Marks <span class="text-danger">*</span></label>
                                <input type="number" class="form-control @error('total_marks') is-invalid @enderror" 
                                       id="total_marks" name="total_marks" value="{{ old('total_marks', 100) }}" 
                                       min="1" max="1000" step="0.01" required>
                                @error('total_marks')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="word_count_min">Min Words</label>
                                        <input type="number" class="form-control @error('word_count_min') is-invalid @enderror" 
                                               id="word_count_min" name="word_count_min" value="{{ old('word_count_min') }}" 
                                               min="0">
                                        @error('word_count_min')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="word_count_max">Max Words</label>
                                        <input type="number" class="form-control @error('word_count_max') is-invalid @enderror" 
                                               id="word_count_max" name="word_count_max" value="{{ old('word_count_max') }}" 
                                               min="0">
                                        @error('word_count_max')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="status">Status <span class="text-danger">*</span></label>
                                <select class="form-control @error('status') is-invalid @enderror" 
                                        id="status" name="status" required>
                                    <option value="draft" {{ old('status', 'draft') == 'draft' ? 'selected' : '' }}>Draft</option>
                                    <option value="published" {{ old('status') == 'published' ? 'selected' : '' }}>Published</option>
                                </select>
                                @error('status')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="attachments">Attachments</label>
                                <input type="file" class="form-control-file @error('attachments') is-invalid @enderror" 
                                       id="attachments" name="attachments[]" multiple>
                                <small class="form-text text-muted">You can upload multiple files (max 10MB each).</small>
                                @error('attachments')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div class="form-group mt-3">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Create Essay
                        </button>
                        <a href="{{ route('admin.essays.index') }}" class="btn btn-secondary">
                            Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

