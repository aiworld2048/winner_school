<?php

namespace App\Http\Middleware;

use App\Enums\UserType;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureHeadTeacher
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = Auth::user();

        if (!$user) {
            abort(403, 'Authentication required.');
        }

        $isHeadTeacherType = $user->type === UserType::HeadTeacher->value;
        $hasHeadTeacherRole = $user->roles()->where('title', 'HeadTeacher')->exists();

        if (!$isHeadTeacherType && !$hasHeadTeacherRole) {
            abort(403, 'Only head teachers can access this section.');
        }

        return $next($request);
    }
}

