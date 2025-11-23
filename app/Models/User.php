<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Enums\UserType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'status' => 'boolean',
            'is_changed_password' => 'boolean',
            'type' => 'integer',
        ];
    }

    /**
     * Get the teacher that this user belongs to.
     */
    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    /**
     * Get the students that belong to this teacher.
     */
    public function students(): HasMany
    {
        return $this->hasMany(User::class, 'teacher_id');
    }

    /**
     * Get the user's roles.
     */
    public function roles()
    {
        return $this->belongsToMany(\App\Models\Admin\Role::class, 'role_user');
    }

    /**
     * Get the user type enum instance.
     */
    public function getUserTypeAttribute(): UserType
    {
        return UserType::from($this->type);
    }

    /**
     * Check if user is of specific type.
     */
    public function isType(UserType $type): bool
    {
        return $this->type === $type->value;
    }

    /**
     * Check if user is admin.
     */
    public function isAdmin(): bool
    {
        return $this->type === UserType::Admin->value;
    }

    /**
     * Check if user is teacher.
     */
    public function isTeacher(): bool
    {
        return $this->type === UserType::Teacher->value;
    }

    /**
     * Check if user is student.
     */
    public function isStudent(): bool
    {
        return $this->type === UserType::Student->value;
    }

    /**
     * Get subjects assigned to this teacher.
     */
    public function subjects(): BelongsToMany
    {
        return $this->belongsToMany(Subject::class, 'teacher_subject', 'teacher_id', 'subject_id')
            ->withPivot('academic_year_id')
            ->withTimestamps();
    }

    /**
     * Get the class this student belongs to.
     */
    public function schoolClass(): BelongsTo
    {
        return $this->belongsTo(SchoolClass::class, 'class_id');
    }

    /**
     * Get classes where this user is the class teacher.
     */
    public function classesAsTeacher(): HasMany
    {
        return $this->hasMany(SchoolClass::class, 'class_teacher_id');
    }

    /**
     * Get exams created by this user (teacher).
     */
    public function createdExams(): HasMany
    {
        return $this->hasMany(Exam::class, 'created_by');
    }

    /**
     * Get the name of the unique identifier for the user.
     *
     * @return string
     */
    public function getAuthIdentifierName()
    {
        return 'id'; // Use 'id' for auth identifier
    }

    /**
     * Get the column name for the "username" (used in authentication).
     *
     * @return string
     */
    public function username()
    {
        return 'phone'; // Use 'phone' for login
    }

    /**
     * Find the user instance for the given username (phone).
     *
     * @param  string  $phone
     * @return \App\Models\User|null
     */
    public function findForPassport($phone)
    {
        return $this->where('phone', $phone)->first();
    }
}
