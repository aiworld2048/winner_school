@php($exam = $exam ?? null)
@csrf
<div class="row">
    <div class="col-md-6">
        <div class="form-group">
            <label for="title">Title <span class="text-danger">*</span></label>
            <input type="text" name="title" id="title" class="form-control @error('title') is-invalid @enderror"
                   value="{{ old('title', optional($exam)->title) }}" required>
            @error('title')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-6">
        <div class="form-group">
            <label for="code">Code <span class="text-danger">*</span></label>
            <input type="text" name="code" id="code" class="form-control @error('code') is-invalid @enderror"
                   value="{{ old('code', optional($exam)->code) }}" required>
            @error('code')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-4">
        <div class="form-group">
            <label for="academic_year_id">Academic Year <span class="text-danger">*</span></label>
            <select name="academic_year_id" id="academic_year_id" class="form-control @error('academic_year_id') is-invalid @enderror" required>
                <option value="">Select Academic Year</option>
                @foreach($academicYears as $year)
                    <option value="{{ $year->id }}" {{ old('academic_year_id', optional($exam)->academic_year_id) == $year->id ? 'selected' : '' }}>
                        {{ $year->name }}
                    </option>
                @endforeach
            </select>
            @error('academic_year_id')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label for="subject_id">Subject <span class="text-danger">*</span></label>
            <select name="subject_id" id="subject_id" class="form-control @error('subject_id') is-invalid @enderror" required>
                <option value="">Select Subject</option>
                @foreach($subjects as $subject)
                    <option value="{{ $subject->id }}" {{ old('subject_id', optional($exam)->subject_id) == $subject->id ? 'selected' : '' }}>
                        {{ $subject->name }}
                    </option>
                @endforeach
            </select>
            @error('subject_id')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label for="class_id">Class <span class="text-danger">*</span></label>
            <select name="class_id" id="class_id" class="form-control @error('class_id') is-invalid @enderror" required>
                <option value="">Select Class</option>
                @foreach($classes as $class)
                    <option value="{{ $class->id }}" {{ old('class_id', optional($exam)->class_id) == $class->id ? 'selected' : '' }}>
                        {{ $class->name }}
                    </option>
                @endforeach
            </select>
            @error('class_id')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-4">
        <div class="form-group">
            <label for="type">Exam Type <span class="text-danger">*</span></label>
            <select name="type" id="type" class="form-control @error('type') is-invalid @enderror" required>
                <option value="quiz" {{ old('type', optional($exam)->type) == 'quiz' ? 'selected' : '' }}>Quiz</option>
                <option value="assignment" {{ old('type', optional($exam)->type) == 'assignment' ? 'selected' : '' }}>Assignment</option>
                <option value="midterm" {{ old('type', optional($exam)->type) == 'midterm' ? 'selected' : '' }}>Midterm</option>
                <option value="final" {{ old('type', optional($exam)->type) == 'final' ? 'selected' : '' }}>Final</option>
                <option value="project" {{ old('type', optional($exam)->type) == 'project' ? 'selected' : '' }}>Project</option>
            </select>
            @error('type')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label for="exam_date">Exam Date & Time <span class="text-danger">*</span></label>
            <input type="datetime-local" name="exam_date" id="exam_date" 
                   class="form-control @error('exam_date') is-invalid @enderror"
                   value="{{ old('exam_date', optional($exam)->exam_date ? $exam->exam_date->format('Y-m-d\TH:i') : '') }}" required>
            @error('exam_date')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label for="duration_minutes">Duration (minutes) <span class="text-danger">*</span></label>
            <input type="number" name="duration_minutes" id="duration_minutes" min="1" max="600"
                   class="form-control @error('duration_minutes') is-invalid @enderror"
                   value="{{ old('duration_minutes', optional($exam)->duration_minutes ?? 60) }}" required>
            @error('duration_minutes')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-4">
        <div class="form-group">
            <label for="total_marks">Total Marks <span class="text-danger">*</span></label>
            <input type="number" name="total_marks" id="total_marks" step="0.01" min="1" max="1000"
                   class="form-control @error('total_marks') is-invalid @enderror"
                   value="{{ old('total_marks', optional($exam)->total_marks ?? 100) }}" required>
            @error('total_marks')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label for="passing_marks">Passing Marks <span class="text-danger">*</span></label>
            <input type="number" name="passing_marks" id="passing_marks" step="0.01" min="0"
                   class="form-control @error('passing_marks') is-invalid @enderror"
                   value="{{ old('passing_marks', optional($exam)->passing_marks ?? 40) }}" required>
            @error('passing_marks')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label for="is_published">Status <span class="text-danger">*</span></label>
            <select name="is_published" id="is_published" class="form-control @error('is_published') is-invalid @enderror" required>
                <option value="0" {{ old('is_published', optional($exam)->is_published ?? 0) == 0 ? 'selected' : '' }}>Draft</option>
                <option value="1" {{ old('is_published', optional($exam)->is_published ?? 0) == 1 ? 'selected' : '' }}>Published</option>
            </select>
            @error('is_published')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="form-group">
    <label for="description">Description</label>
    <textarea name="description" id="description" class="form-control @error('description') is-invalid @enderror">{{ old('description', optional($exam)->description) }}</textarea>
    @error('description')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
    <small class="form-text text-muted">
        <i class="fas fa-info-circle"></i> Use the toolbar to format text. For math equations, use LaTeX syntax: <code>\(x^2 + y^2 = z^2\)</code> for inline math or <code>\[E = mc^2\]</code> for display math.
    </small>
</div>

<div class="form-group">
    <label for="pdf_file">PDF File</label>
    <input type="file" name="pdf_file" id="pdf_file" class="form-control-file @error('pdf_file') is-invalid @enderror" accept=".pdf">
    @error('pdf_file')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
    @if(optional($exam)->pdf_file)
        <small class="form-text text-muted">
            <i class="fas fa-file-pdf text-danger"></i> Current PDF: 
            <a href="{{ asset('storage/' . $exam->pdf_file) }}" target="_blank">{{ basename($exam->pdf_file) }}</a>
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
    <a href="{{ route('admin.exams.index') }}" class="btn btn-secondary mr-2">Cancel</a>
    <button type="submit" class="btn btn-primary">{{ $submitLabel ?? 'Save' }}</button>
</div>

