@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h1 class="m-0">Assign Subjects</h1>
            <p class="mb-0 text-muted">{{ $teacher->name ?? $teacher->user_name }}</p>
        </div>
        <a href="{{ route('admin.teachers.index') }}" class="btn btn-secondary">Back to Teachers</a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.teachers.subjects.store', $teacher) }}" method="POST">
                    @csrf
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Subject</th>
                                    <th>Assign</th>
                                    <th>Academic Year</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($subjects as $subject)
                                    @php
                                        $assignedYear = $existing[$subject->id] ?? null;
                                    @endphp
                                    <tr>
                                        <td>{{ $subject->name }} <span class="text-muted">({{ $subject->code }})</span></td>
                                        <td>
                                            <input type="checkbox" name="subjects[{{ $subject->id }}][enabled]"
                                                   value="1"
                                                   {{ array_key_exists($subject->id, $existing) ? 'checked' : '' }}
                                                   class="subject-toggle"
                                                   data-target="#subject-year-{{ $subject->id }}">
                                        </td>
                                        <td>
                                            <select name="subjects[{{ $subject->id }}][academic_year_id]"
                                                    id="subject-year-{{ $subject->id }}"
                                                    class="form-control"
                                                    {{ array_key_exists($subject->id, $existing) ? '' : 'disabled' }}>
                                                <option value="">-- Select --</option>
                                                @foreach($academicYears as $year)
                                                    <option value="{{ $year->id }}" {{ $assignedYear == $year->id ? 'selected' : '' }}>
                                                        {{ $year->name }}
                                                    </option>
                                                @endforeach
                                            </select>
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>

                    <div class="d-flex justify-content-end">
                        <button type="submit" class="btn btn-primary">Save Assignments</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

@section('script')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.subject-toggle').forEach(function (checkbox) {
            checkbox.addEventListener('change', function () {
                const select = document.querySelector(this.dataset.target);
                if (select) {
                    select.disabled = !this.checked;
                    if (!this.checked) {
                        select.value = '';
                    }
                }
            });
        });
    });
</script>
@endsection

