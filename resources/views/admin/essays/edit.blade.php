@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Edit Essay</h1>
        <a href="{{ route('admin.essays.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.essays.update', $essay) }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    @method('PUT')
                    
                    <div class="row">
                        <div class="col-md-8">
                            <div class="form-group">
                                <label for="title">Title <span class="text-danger">*</span></label>
                                <input type="text" class="form-control @error('title') is-invalid @enderror" 
                                       id="title" name="title" value="{{ old('title', $essay->title) }}" required>
                                @error('title')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="description">Description</label>
                                <textarea class="form-control @error('description') is-invalid @enderror" 
                                          id="description" name="description" rows="3">{{ old('description', $essay->description) }}</textarea>
                                @error('description')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="instructions">Instructions</label>
                                <textarea class="form-control @error('instructions') is-invalid @enderror" 
                                          id="instructions" name="instructions" rows="6">{{ old('instructions', $essay->instructions) }}</textarea>
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
                                        <option value="{{ $subject->id }}" {{ old('subject_id', $essay->subject_id) == $subject->id ? 'selected' : '' }}>
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
                                        <option value="{{ $class->id }}" {{ old('class_id', $essay->class_id) == $class->id ? 'selected' : '' }}>
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
                                        <option value="{{ $year->id }}" {{ old('academic_year_id', $essay->academic_year_id) == $year->id ? 'selected' : '' }}>
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
                                       id="due_date" name="due_date" value="{{ old('due_date', $essay->due_date->format('Y-m-d')) }}" required>
                                @error('due_date')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="due_time">Due Time</label>
                                <input type="time" class="form-control @error('due_time') is-invalid @enderror" 
                                       id="due_time" name="due_time" value="{{ old('due_time', $essay->due_time ? \Carbon\Carbon::parse($essay->due_time)->format('H:i') : '') }}">
                                @error('due_time')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="form-group">
                                <label for="total_marks">Total Marks <span class="text-danger">*</span></label>
                                <input type="number" class="form-control @error('total_marks') is-invalid @enderror" 
                                       id="total_marks" name="total_marks" value="{{ old('total_marks', $essay->total_marks) }}" 
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
                                               id="word_count_min" name="word_count_min" value="{{ old('word_count_min', $essay->word_count_min) }}" 
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
                                               id="word_count_max" name="word_count_max" value="{{ old('word_count_max', $essay->word_count_max) }}" 
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
                                    <option value="draft" {{ old('status', $essay->status) == 'draft' ? 'selected' : '' }}>Draft</option>
                                    <option value="published" {{ old('status', $essay->status) == 'published' ? 'selected' : '' }}>Published</option>
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
                                @if($essay->attachments && count($essay->attachments) > 0)
                                    <div class="mt-2">
                                        <small class="text-muted">Current attachments:</small>
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

                            <div class="form-group">
                                <label for="pdf_file">PDF File</label>
                                <input type="file" class="form-control-file @error('pdf_file') is-invalid @enderror" 
                                       id="pdf_file" name="pdf_file" accept=".pdf">
                                @error('pdf_file')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                                @if($essay->pdf_file)
                                    <small class="form-text text-muted">
                                        <i class="fas fa-file-pdf text-danger"></i> Current PDF: 
                                        <a href="{{ asset('storage/' . $essay->pdf_file) }}" target="_blank">{{ basename($essay->pdf_file) }}</a>
                                        <br>
                                        <span class="text-muted">Upload a new file to replace the existing PDF.</span>
                                    </small>
                                @else
                                    <small class="form-text text-muted">
                                        <i class="fas fa-info-circle"></i> Upload a PDF file (max 10MB). Optional.
                                    </small>
                                @endif
                            </div>
                        </div>
                    </div>

                    <div class="form-group mt-3">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Update Essay
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

