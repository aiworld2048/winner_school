@php($academicYear = $academicYear ?? null)
@csrf
<div class="row">
    <div class="col-md-6">
        <div class="form-group">
            <label for="name">Name</label>
            <input type="text" name="name" id="name" class="form-control @error('name') is-invalid @enderror"
                   value="{{ old('name', optional($academicYear)->name) }}" required>
            @error('name')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-6">
        <div class="form-group">
            <label for="code">Code</label>
            <input type="text" name="code" id="code" class="form-control @error('code') is-invalid @enderror"
                   value="{{ old('code', optional($academicYear)->code) }}" required>
            @error('code')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="form-group">
            <label for="start_date">Start Date</label>
            <input type="date" name="start_date" id="start_date" class="form-control @error('start_date') is-invalid @enderror"
                   value="{{ old('start_date', optional(optional($academicYear)->start_date)->format('Y-m-d')) }}" required>
            @error('start_date')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-6">
        <div class="form-group">
            <label for="end_date">End Date</label>
            <input type="date" name="end_date" id="end_date" class="form-control @error('end_date') is-invalid @enderror"
                   value="{{ old('end_date', optional(optional($academicYear)->end_date)->format('Y-m-d')) }}" required>
            @error('end_date')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="form-group">
    <label for="description">Description</label>
    <textarea name="description" id="description" rows="3" class="form-control @error('description') is-invalid @enderror">{{ old('description', optional($academicYear)->description) }}</textarea>
    @error('description')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="form-group">
    <label for="is_active">Status</label>
    <select name="is_active" id="is_active" class="form-control @error('is_active') is-invalid @enderror" required>
        <option value="1" {{ old('is_active', optional($academicYear)->is_active ?? 0) == 1 ? 'selected' : '' }}>Active</option>
        <option value="0" {{ old('is_active', optional($academicYear)->is_active ?? 0) == 0 ? 'selected' : '' }}>Inactive</option>
    </select>
    @error('is_active')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="d-flex justify-content-end">
    <a href="{{ route('admin.academic-years.index') }}" class="btn btn-secondary mr-2">Cancel</a>
    <button type="submit" class="btn btn-primary">{{ $submitLabel ?? 'Save' }}</button>
</div>

