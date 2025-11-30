@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">Edit Dictionary Entry</h1>
        <a href="{{ route('admin.dictionary.index') }}" class="btn btn-secondary">Back to list</a>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <form action="{{ route('admin.dictionary.update', $entry) }}" method="POST">
                @csrf
                @method('PUT')
                <div class="card-body">
                    <div class="form-group">
                        <label for="english_word">English Word</label>
                        <input type="text" class="form-control @error('english_word') is-invalid @enderror" id="english_word" name="english_word" value="{{ old('english_word', $entry->english_word) }}" required>
                        @error('english_word')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    <div class="form-group">
                        <label for="myanmar_meaning">Myanmar Meaning</label>
                        <input type="text" class="form-control @error('myanmar_meaning') is-invalid @enderror" id="myanmar_meaning" name="myanmar_meaning" value="{{ old('myanmar_meaning', $entry->myanmar_meaning) }}" required>
                        @error('myanmar_meaning')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    <div class="form-group">
                        <label for="example">Example Sentence</label>
                        <textarea class="form-control @error('example') is-invalid @enderror" id="example" name="example" rows="3">{{ old('example', $entry->example) }}</textarea>
                        @error('example')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>
                <div class="card-footer text-right">
                    <button type="submit" class="btn btn-primary">Update</button>
                </div>
            </form>
        </div>
    </div>
</section>
@endsection

