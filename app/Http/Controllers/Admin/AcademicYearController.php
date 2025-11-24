<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AcademicYearController extends Controller
{
    public function __construct()
    {
        $this->middleware('head_teacher');
    }

    public function index()
    {
        $academicYears = AcademicYear::orderByDesc('start_date')->paginate(15);

        return view('admin.academic_years.index', compact('academicYears'));
    }

    public function create()
    {
        return view('admin.academic_years.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:academic_years,name'],
            'code' => ['required', 'string', 'max:50', 'unique:academic_years,code'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after:start_date'],
            'description' => ['nullable', 'string'],
            'is_active' => ['required', 'boolean'],
        ]);

        $academicYear = AcademicYear::create([
            'name' => $data['name'],
            'code' => $data['code'],
            'start_date' => $data['start_date'],
            'end_date' => $data['end_date'],
            'description' => $data['description'] ?? null,
            'is_active' => $data['is_active'],
            'created_by' => Auth::id(),
        ]);

        $this->syncActiveFlag($academicYear);

        return redirect()
            ->route('admin.academic-years.index')
            ->with('success', 'Academic year created successfully.');
    }

    public function edit(AcademicYear $academicYear)
    {
        return view('admin.academic_years.edit', compact('academicYear'));
    }

    public function update(Request $request, AcademicYear $academicYear)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:academic_years,name,'.$academicYear->id],
            'code' => ['required', 'string', 'max:50', 'unique:academic_years,code,'.$academicYear->id],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after:start_date'],
            'description' => ['nullable', 'string'],
            'is_active' => ['required', 'boolean'],
        ]);

        $academicYear->update([
            'name' => $data['name'],
            'code' => $data['code'],
            'start_date' => $data['start_date'],
            'end_date' => $data['end_date'],
            'description' => $data['description'] ?? null,
            'is_active' => $data['is_active'],
        ]);

        $this->syncActiveFlag($academicYear);

        return redirect()
            ->route('admin.academic-years.index')
            ->with('success', 'Academic year updated successfully.');
    }

    public function destroy(AcademicYear $academicYear)
    {
        $academicYear->delete();

        return redirect()
            ->route('admin.academic-years.index')
            ->with('success', 'Academic year removed.');
    }

    private function syncActiveFlag(AcademicYear $academicYear): void
    {
        if ($academicYear->is_active) {
            AcademicYear::where('id', '<>', $academicYear->id)->update(['is_active' => false]);
        }
    }
}

