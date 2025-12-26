@php($classes = $classes ?? collect())
@php($lesson = $lesson ?? null)
@csrf
<div class="form-group">
    <label for="title">Title</label>
    <input type="text" name="title" id="title" class="form-control @error('title') is-invalid @enderror"
           value="{{ old('title', optional($lesson)->title) }}" required>
    @error('title')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="form-group">
    <label for="class_id">Class</label>
    <select name="class_id" id="class_id" class="form-control @error('class_id') is-invalid @enderror" required>
        <option value="" disabled selected>Select class</option>
        @foreach($classes as $class)
            <option value="{{ $class->id }}" {{ old('class_id', optional($lesson)->class_id) == $class->id ? 'selected' : '' }}>
                {{ $class->name }}
            </option>
        @endforeach
    </select>
    @error('class_id')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="form-group">
    <label for="subject_id">Subject</label>
    <select name="subject_id" id="subject_id" class="form-control @error('subject_id') is-invalid @enderror" required>
        <option value="" disabled selected>Select subject</option>
        @foreach(Auth::user()->subjects as $subject)
            <option value="{{ $subject->id }}" {{ old('subject_id', optional($lesson)->subject_id) == $subject->id ? 'selected' : '' }}>
                {{ $subject->name }}
            </option>
        @endforeach
    </select>
    @error('subject_id')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="form-group">
    <label for="lesson_date">Lesson Date</label>
    <input type="date" name="lesson_date" id="lesson_date" class="form-control @error('lesson_date') is-invalid @enderror"
           value="{{ old('lesson_date', optional(optional($lesson)->lesson_date)->format('Y-m-d')) }}" required>
    @error('lesson_date')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="form-group">
    <label for="duration_minutes">Duration (minutes)</label>
    <input type="number" name="duration_minutes" id="duration_minutes" class="form-control @error('duration_minutes') is-invalid @enderror"
           value="{{ old('duration_minutes', optional($lesson)->duration_minutes ?? 45) }}">
    @error('duration_minutes')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="form-group">
    <label for="description">Description</label>
    <textarea name="description" id="description" rows="3" class="form-control @error('description') is-invalid @enderror">{{ old('description', optional($lesson)->description) }}</textarea>
    @error('description')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="form-group">
    <label for="content">Content</label>
    <textarea name="content" id="content-editor" rows="5" class="form-control @error('content') is-invalid @enderror">{{ old('content', optional($lesson ?? null)->content) }}</textarea>
    @error('content')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="form-group">
    <label for="pdf_file">PDF File</label>
    <input type="file" name="pdf_file" id="pdf_file" class="form-control-file @error('pdf_file') is-invalid @enderror" accept=".pdf">
    @error('pdf_file')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
    @if(optional($lesson)->pdf_file)
        <small class="form-text text-muted">
            <i class="fas fa-file-pdf text-danger"></i> Current PDF: 
            <a href="{{ asset('storage/' . $lesson->pdf_file) }}" target="_blank">{{ basename($lesson->pdf_file) }}</a>
            <br>
            <span class="text-muted">Upload a new file to replace the existing PDF.</span>
        </small>
    @else
        <small class="form-text text-muted">
            <i class="fas fa-info-circle"></i> Upload a PDF file (max 10MB). Optional.
        </small>
    @endif
</div>

<div class="d-flex justify-content-end">
    <a href="{{ route('teacher.lessons.index') }}" class="btn btn-secondary mr-2">Cancel</a>
    <button type="submit" class="btn btn-primary">{{ $submitLabel ?? 'Save' }}</button>
</div>

