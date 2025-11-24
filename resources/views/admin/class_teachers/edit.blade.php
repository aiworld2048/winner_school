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
                        <label for="class_teacher_id">Teacher</label>
                        <select name="class_teacher_id" id="class_teacher_id" class="form-control @error('class_teacher_id') is-invalid @enderror">
                            <option value="">Unassigned</option>
                            @foreach($teachers as $teacher)
                                <option value="{{ $teacher->id }}" {{ old('class_teacher_id', $schoolClass->class_teacher_id) == $teacher->id ? 'selected' : '' }}>
                                    {{ $teacher->name ?? $teacher->user_name }}
                                </option>
                            @endforeach
                        </select>
                        @error('class_teacher_id')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="d-flex justify-content-end">
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

