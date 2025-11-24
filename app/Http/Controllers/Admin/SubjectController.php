<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SubjectController extends Controller
{
    public function __construct()
    {
        $this->middleware('head_teacher');
    }

    public function index()
    {
        $subjects = Subject::orderBy('name')->paginate(15);

        return view('admin.subjects.index', compact('subjects'));
    }

    public function create()
    {
        return view('admin.subjects.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:subjects,name'],
            'code' => ['required', 'string', 'max:50', 'unique:subjects,code'],
            'credit_hours' => ['required', 'integer', 'min:1', 'max:20'],
            'description' => ['nullable', 'string'],
            'is_active' => ['required', 'boolean'],
        ]);

        Subject::create([
            'name' => $data['name'],
            'code' => $data['code'],
            'credit_hours' => $data['credit_hours'],
            'description' => $data['description'] ?? null,
            'is_active' => $data['is_active'],
            'created_by' => Auth::id(),
        ]);

        return redirect()
            ->route('admin.subjects.index')
            ->with('success', 'Subject created successfully.');
    }

    public function edit(Subject $subject)
    {
        return view('admin.subjects.edit', compact('subject'));
    }

    public function update(Request $request, Subject $subject)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:subjects,name,'.$subject->id],
            'code' => ['required', 'string', 'max:50', 'unique:subjects,code,'.$subject->id],
            'credit_hours' => ['required', 'integer', 'min:1', 'max:20'],
            'description' => ['nullable', 'string'],
            'is_active' => ['required', 'boolean'],
        ]);

        $subject->update([
            'name' => $data['name'],
            'code' => $data['code'],
            'credit_hours' => $data['credit_hours'],
            'description' => $data['description'] ?? null,
            'is_active' => $data['is_active'],
        ]);

        return redirect()
            ->route('admin.subjects.index')
            ->with('success', 'Subject updated successfully.');
    }

    public function destroy(Subject $subject)
    {
        $subject->delete();

        return redirect()
            ->route('admin.subjects.index')
            ->with('success', 'Subject removed.');
    }
}

