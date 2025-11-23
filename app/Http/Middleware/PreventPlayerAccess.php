<?php

namespace App\Http\Middleware;

use App\Enums\UserType;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class PreventPlayerAccess
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (Auth::check()) {
            $user = Auth::user();
            $userType = UserType::from($user->type);

            // If user is a student, deny access to admin routes
            if ($userType === UserType::Student) {
                Auth::logout();
                
                return redirect()->route('login')
                    ->with('error', 'Students are not allowed to access the admin panel. Please use the student application.');
            }
        }

        return $next($request);
    }
}

