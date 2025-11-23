@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Create Teacher</h1>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.teachers.store') }}" method="POST">
                    @include('admin.teachers._form', ['submitLabel' => 'Create', 'teacher' => null])
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

