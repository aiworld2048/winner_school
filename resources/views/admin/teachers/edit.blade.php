@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Edit Teacher</h1>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.teachers.update', $teacher) }}" method="POST">
                    @method('PUT')
                    @include('admin.teachers._form', ['submitLabel' => 'Update'])
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

