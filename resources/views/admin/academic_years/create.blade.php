@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Create Academic Year</h1>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.academic-years.store') }}" method="POST">
                    @include('admin.academic_years._form', ['submitLabel' => 'Create', 'academicYear' => null])
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

