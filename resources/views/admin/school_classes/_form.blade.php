@php($schoolClass = $schoolClass ?? null)
@csrf
<div class="row">
    <div class="col-md-6">
        <div class="form-group">
            <label for="name">Class Name</label>
            <input type="text" name="name" id="name" class="form-control @error('name') is-invalid @enderror"
                   value="{{ old('name', optional($schoolClass)->name) }}" required>
            @error('name')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-6">
        <div class="form-group">
            <label for="code">Code</label>
            <input type="text" name="code" id="code" class="form-control @error('code') is-invalid @enderror"
                   value="{{ old('code', optional($schoolClass)->code) }}" required>
            @error('code')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-4">
        <div class="form-group">
            <label for="grade_level">Grade Level</label>
            <input type="number" name="grade_level" id="grade_level" min="0" max="12"
                   class="form-control @error('grade_level') is-invalid @enderror"
                   value="{{ old('grade_level', optional($schoolClass)->grade_level ?? 0) }}" required>
            @error('grade_level')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label for="section">Section</label>
            <input type="text" name="section" id="section" class="form-control @error('section') is-invalid @enderror"
                   value="{{ old('section', optional($schoolClass)->section) }}">
            @error('section')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label for="capacity">Capacity</label>
            <input type="number" name="capacity" id="capacity" min="1" max="100"
                   class="form-control @error('capacity') is-invalid @enderror"
                   value="{{ old('capacity', optional($schoolClass)->capacity ?? 30) }}" required>
            @error('capacity')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="form-group">
            <label for="academic_year_id">Academic Year</label>
            <select name="academic_year_id" id="academic_year_id" class="form-control @error('academic_year_id') is-invalid @enderror" required>
                <option value="" disabled {{ old('academic_year_id', optional($schoolClass)->academic_year_id) ? '' : 'selected' }}>Select academic year</option>
                @foreach($academicYears as $year)
                    <option value="{{ $year->id }}" {{ old('academic_year_id', optional($schoolClass)->academic_year_id) == $year->id ? 'selected' : '' }}>
                        {{ $year->name }}
                    </option>
                @endforeach
            </select>
            @error('academic_year_id')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-6">
        <div class="form-group">
            <label for="class_teacher_id">Class Teacher</label>
            <select name="class_teacher_id" id="class_teacher_id" class="form-control @error('class_teacher_id') is-invalid @enderror">
                <option value="">Unassigned</option>
                @foreach($teachers as $teacher)
                    <option value="{{ $teacher->id }}" {{ old('class_teacher_id', optional($schoolClass)->class_teacher_id) == $teacher->id ? 'selected' : '' }}>
                        {{ $teacher->name ?? $teacher->user_name }}
                    </option>
                @endforeach
            </select>
            @error('class_teacher_id')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="form-group">
    <label for="is_active">Status</label>
    <select name="is_active" id="is_active" class="form-control @error('is_active') is-invalid @enderror" required>
        <option value="1" {{ old('is_active', optional($schoolClass)->is_active ?? 1) == 1 ? 'selected' : '' }}>Active</option>
        <option value="0" {{ old('is_active', optional($schoolClass)->is_active ?? 1) == 0 ? 'selected' : '' }}>Inactive</option>
    </select>
    @error('is_active')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="d-flex justify-content-end">
    <a href="{{ route('admin.school-classes.index') }}" class="btn btn-secondary mr-2">Cancel</a>
    <button type="submit" class="btn btn-primary">{{ $submitLabel ?? 'Save' }}</button>
</div>

