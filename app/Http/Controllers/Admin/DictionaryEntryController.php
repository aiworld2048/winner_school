<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DictionaryEntry;
use Illuminate\Http\Request;

class DictionaryEntryController extends Controller
{
    public function index()
    {
        $entries = DictionaryEntry::orderBy('english_word')->paginate(20);

        return view('admin.dictionary.index', compact('entries'));
    }

    public function create()
    {
        return view('admin.dictionary.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'english_word' => ['required', 'string', 'max:255', 'unique:dictionary_entries,english_word'],
            'myanmar_meaning' => ['required', 'string', 'max:255'],
            'example' => ['nullable', 'string'],
        ]);

        DictionaryEntry::create($data);

        return redirect()->route('admin.dictionary.index')->with('success', 'Entry created successfully.');
    }

    public function edit(DictionaryEntry $dictionary)
    {
        return view('admin.dictionary.edit', ['entry' => $dictionary]);
    }

    public function update(Request $request, DictionaryEntry $dictionary)
    {
        $data = $request->validate([
            'english_word' => ['required', 'string', 'max:255', 'unique:dictionary_entries,english_word,' . $dictionary->id],
            'myanmar_meaning' => ['required', 'string', 'max:255'],
            'example' => ['nullable', 'string'],
        ]);

        $dictionary->update($data);

        return redirect()->route('admin.dictionary.index')->with('success', 'Entry updated successfully.');
    }

    public function destroy(DictionaryEntry $dictionary)
    {
        $dictionary->delete();

        return redirect()->route('admin.dictionary.index')->with('success', 'Entry deleted successfully.');
    }
}

