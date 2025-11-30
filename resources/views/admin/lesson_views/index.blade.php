@extends('layouts.master')

@section('content')
    <div class="content-wrapper">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1>Lesson engagement</h1>
                        <p class="text-muted mb-0">Track how often students open each lesson.</p>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item"><a href="{{ route('admin.home') }}">Dashboard</a></li>
                            <li class="breadcrumb-item active">Lesson engagement</li>
                        </ol>
                    </div>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <form method="GET" class="mb-4">
                            <div class="form-row align-items-end">
                                <div class="form-group col-md-3">
                                    <label for="class_id">Class</label>
                                    <select name="class_id" id="class_id" class="form-control">
                                        <option value="">All classes</option>
                                        @foreach($classes as $id => $name)
                                            <option value="{{ $id }}" {{ $filters['class_id'] == $id ? 'selected' : '' }}>
                                                {{ $name }}
                                            </option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="form-group col-md-3">
                                    <label for="subject_id">Subject</label>
                                    <select name="subject_id" id="subject_id" class="form-control">
                                        <option value="">All subjects</option>
                                        @foreach($subjects as $id => $name)
                                            <option value="{{ $id }}" {{ $filters['subject_id'] == $id ? 'selected' : '' }}>
                                                {{ $name }}
                                            </option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="form-group col-md-3">
                                    <label for="student">Student</label>
                                    <input type="text" name="student" id="student" class="form-control"
                                           placeholder="Name, phone or ID"
                                           value="{{ $filters['student'] }}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label for="lesson">Lesson</label>
                                    <input type="text" name="lesson" id="lesson" class="form-control"
                                           placeholder="Lesson title"
                                           value="{{ $filters['lesson'] }}">
                                </div>
                            </div>
                            <div class="d-flex justify-content-end">
                                <a href="{{ route('admin.lesson-views.index') }}" class="btn btn-outline-secondary mr-2">
                                    Reset
                                </a>
                                <button class="btn btn-primary" type="submit">
                                    <i class="fas fa-filter mr-1"></i>Filter
                                </button>
                            </div>
                        </form>

                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Class</th>
                                    <th>Lesson</th>
                                    <th>Subject</th>
                                    <th class="text-center">Views</th>
                                    <th>Last viewed</th>
                                </tr>
                                </thead>
                                <tbody>
                                @forelse($views as $view)
                                    <tr>
                                        <td>
                                            <strong>{{ $view->student?->name ?? 'Unknown student' }}</strong>
                                            <div class="text-muted small">
                                                {{ $view->student?->user_name }} · {{ $view->student?->phone }}
                                            </div>
                                        </td>
                                        <td>
                                            {{ $view->lesson?->class?->name ?? '—' }}
                                        </td>
                                        <td>
                                            <div class="font-weight-bold">{{ $view->lesson?->title ?? 'Removed lesson' }}</div>
                                            <div class="small text-muted">
                                                Teacher: {{ $view->lesson?->teacher?->name ?? 'N/A' }}
                                            </div>
                                        </td>
                                        <td>{{ $view->lesson?->subject?->name ?? '—' }}</td>
                                        <td class="text-center font-weight-bold">
                                            {{ number_format($view->amount) }}
                                        </td>
                                        <td>
                                            {{ optional($view->updated_at)->format('d M Y, h:i A') ?? '—' }}
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="6" class="text-center py-5">
                                            <i class="fas fa-info-circle fa-2x mb-2 text-muted"></i>
                                            <p class="mb-0">No lesson activity found with the current filters.</p>
                                        </td>
                                    </tr>
                                @endforelse
                                </tbody>
                            </table>
                        </div>

                        <div class="mt-3">
                            {{ $views->links() }}
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
@endsection

