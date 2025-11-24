@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Edit Lesson</h1>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-body">
                <form action="{{ route('teacher.lessons.update', $lesson) }}" method="POST">
                    @csrf
                    @method('PUT')
                    @include('teacher.lessons._form', ['classes' => $classes, 'lesson' => $lesson, 'submitLabel' => 'Update'])
                </form>
            </div>
        </div>
    </div>
</section>
@endsection

@section('script')
<script>
    $(function () {
        var editor = $('#content-editor');
        if (editor.length) {
            editor.summernote({
                height: 200,
                toolbar: [
                    ['style', ['bold', 'italic', 'underline', 'clear']],
                    ['para', ['ul', 'ol', 'paragraph']],
                    ['insert', ['link']],
                    ['view', ['fullscreen', 'codeview']]
                ]
            });
        }
    });
</script>
@endsection

