<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ContactResource;
use App\Models\Contact;
use App\Models\User;
use App\Traits\HttpResponses;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ContactController extends Controller
{
    use HttpResponses;

    public function get()
    {
        $teacher = Auth::user();

        $contact = Contact::where('teacher_id', $teacher->id)->get();
        // $contact = Contact::get();

        return $this->success(ContactResource::collection($contact));
    }
}
