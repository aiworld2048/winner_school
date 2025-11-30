@extends('layouts.master')

@section('content')
<div class="content-header">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="m-0">English ➜ Myanmar Dictionary</h1>
    </div>
</div>

<section class="content">
    <div class="container-fluid">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <a href="{{ route('admin.dictionary.create') }}" class="btn btn-primary">
                    <i class="fas fa-plus-circle"></i> Add Entry
                </a>
                @if(session('success'))
                    <span class="text-success">{{ session('success') }}</span>
                @endif
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
                        <thead>
                            <tr>
                                <th>English Word</th>
                                <th>Myanmar Meaning</th>
                                <th>Example (အင်္ဂလိပ်ဝါကျ)</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($entries as $entry)
                                <tr>
                                    <td class="font-weight-bold">{{ $entry->english_word }}</td>
                                    <td>{{ $entry->myanmar_meaning }}</td>
                                    <td>{{ $entry->example }}</td>
                                    <td class="text-right">
                                        <a href="{{ route('admin.dictionary.edit', $entry) }}" class="btn btn-sm btn-outline-primary">Edit</a>
                                        <form action="{{ route('admin.dictionary.destroy', $entry) }}" method="POST" class="d-inline">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this entry?')">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="4" class="text-center py-4 text-muted">
                                        No dictionary entries found.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer">
                {{ $entries->links() }}
            </div>
        </div>
    </div>
</section>
@endsection

