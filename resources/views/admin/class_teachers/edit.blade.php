@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h1 class="m-0">Assign Class Teacher</h1>
            <p class="mb-0 text-muted">{{ $schoolClass->name }} ({{ $schoolClass->code }})</p>
        </div>
        <a href="{{ route('admin.school-classes.index') }}" class="btn btn-secondary">Back to Classes</a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.school-classes.teacher.update', $schoolClass) }}" method="POST">
                    @csrf
                    @method('PUT')

                    <div class="form-group">
                        <label for="teacher_ids">Teachers <span class="text-muted">(Select multiple)</span></label>
                        <select name="teacher_ids[]" id="teacher_ids" class="form-control @error('teacher_ids') is-invalid @enderror" multiple size="8">
                            @foreach($teachers as $teacher)
                                <option value="{{ $teacher->id }}" {{ in_array($teacher->id, old('teacher_ids', $assignedTeacherIds ?? [])) ? 'selected' : '' }}>
                                    {{ $teacher->name ?? $teacher->user_name }}
                                </option>
                            @endforeach
                        </select>
                        <small class="form-text text-muted">
                            Hold <kbd>Ctrl</kbd> (Windows) or <kbd>Cmd</kbd> (Mac) to select multiple teachers.
                        </small>
                        @error('teacher_ids')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                        @error('teacher_ids.*')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label for="primary_teacher_id">Primary Teacher</label>
                        <select name="primary_teacher_id" id="primary_teacher_id" class="form-control @error('primary_teacher_id') is-invalid @enderror">
                            <option value="">No Primary Teacher</option>
                            @foreach($teachers as $teacher)
                                <option value="{{ $teacher->id }}" {{ old('primary_teacher_id', $primaryTeacherId ?? $schoolClass->class_teacher_id) == $teacher->id ? 'selected' : '' }}>
                                    {{ $teacher->name ?? $teacher->user_name }}
                                </option>
                            @endforeach
                        </select>
                        <small class="form-text text-muted">
                            Select the primary class teacher. This teacher will be set as the main class teacher.
                        </small>
                        @error('primary_teacher_id')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i>
                        <strong>Note:</strong> You can assign multiple teachers to this class. The primary teacher will be set as the main class teacher for backward compatibility.
                    </div>

                    <div class="d-flex justify-content-end">
                        <a href="{{ route('admin.school-classes.index') }}" class="btn btn-secondary mr-2">Cancel</a>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

