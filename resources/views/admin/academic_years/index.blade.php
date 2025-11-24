@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Academic Years</h1>
        <a href="{{ route('admin.academic-years.create') }}" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Academic Year
        </a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Code</th>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Status</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($academicYears as $year)
                                <tr>
                                    <td>{{ $year->name }}</td>
                                    <td>{{ $year->code }}</td>
                                    <td>{{ optional($year->start_date)->format('Y-m-d') }}</td>
                                    <td>{{ optional($year->end_date)->format('Y-m-d') }}</td>
                                    <td>
                                        <span class="badge {{ $year->is_active ? 'badge-success' : 'badge-secondary' }}">
                                            {{ $year->is_active ? 'Active' : 'Inactive' }}
                                        </span>
                                    </td>
                                    <td class="text-right">
                                        <a href="{{ route('admin.academic-years.edit', $year) }}" class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <form action="{{ route('admin.academic-years.destroy', $year) }}" method="POST" class="d-inline"
                                              onsubmit="return confirm('Delete this academic year?');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="text-center py-4">No academic years found.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer">
                {{ $academicYears->links() }}
            </div>
        </div>
    </div>
</section>
@endsection

