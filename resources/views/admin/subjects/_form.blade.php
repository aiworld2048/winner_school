@php($subject = $subject ?? null)
@csrf
<div class="row">
    <div class="col-md-6">
        <div class="form-group">
            <label for="name">Name</label>
            <input type="text" name="name" id="name" class="form-control @error('name') is-invalid @enderror"
                   value="{{ old('name', optional($subject)->name) }}" required>
            @error('name')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-6">
        <div class="form-group">
            <label for="code">Code</label>
            <input type="text" name="code" id="code" class="form-control @error('code') is-invalid @enderror"
                   value="{{ old('code', optional($subject)->code) }}" required>
            @error('code')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="form-group">
            <label for="credit_hours">Credit Hours</label>
            <input type="number" name="credit_hours" id="credit_hours" min="1" max="20"
                   class="form-control @error('credit_hours') is-invalid @enderror"
                   value="{{ old('credit_hours', optional($subject)->credit_hours ?? 1) }}" required>
            @error('credit_hours')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
    <div class="col-md-6">
        <div class="form-group">
            <label for="is_active">Status</label>
            <select name="is_active" id="is_active" class="form-control @error('is_active') is-invalid @enderror">
                <option value="1" {{ old('is_active', optional($subject)->is_active ?? 1) == 1 ? 'selected' : '' }}>Active</option>
                <option value="0" {{ old('is_active', optional($subject)->is_active ?? 1) == 0 ? 'selected' : '' }}>Inactive</option>
            </select>
            @error('is_active')
                <div class="invalid-feedback">{{ $message }}</div>
            @enderror
        </div>
    </div>
</div>

<div class="form-group">
    <label for="description">Description</label>
    <textarea name="description" id="description" rows="3" class="form-control @error('description') is-invalid @enderror">{{ old('description', optional($subject)->description) }}</textarea>
    @error('description')
        <div class="invalid-feedback">{{ $message }}</div>
    @enderror
</div>

<div class="d-flex justify-content-end">
    <a href="{{ route('admin.subjects.index') }}" class="btn btn-secondary mr-2">Cancel</a>
    <button type="submit" class="btn btn-primary">{{ $submitLabel ?? 'Save' }}</button>
</div>

