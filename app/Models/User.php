<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Enums\UserType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\DB;
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
        'user_name',
        'email',
        'phone',
        'password',
        'profile',
        'balance',
        'status',
        'is_changed_password',
        'teacher_id',
        'class_id',
        'payment_type_id',
        'account_name',
        'account_number',
        'type',
        'subject_id',
        'academic_year_id',
        'referral_code',
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
            'class_id' => 'integer',
            'subject_id' => 'integer',
            'academic_year_id' => 'integer',
            'referral_code' => 'string',
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
     * Get the subject assigned to this student (if any).
     */
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class, 'subject_id');
    }

    /**
     * Get the academic year associated with this student.
     */
    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class, 'academic_year_id');
    }

    /**
     * Personal notes created by the student.
     */
    public function studentNotes(): HasMany
    {
        return $this->hasMany(StudentNote::class);
    }

    /**
     * Get classes where this user is the class teacher.
     * Returns classes from both legacy (class_teacher_id) and new (class_teacher pivot) relationships.
     */
    public function classesAsTeacher()
    {
        // Get class IDs from both relationships
        $legacyClassIds = SchoolClass::where('class_teacher_id', $this->id)->pluck('id');
        $manyToManyClassIds = DB::table('class_teacher')
            ->where('teacher_id', $this->id)
            ->pluck('class_id');
        
        // Merge and get unique class IDs
        $allClassIds = $legacyClassIds->merge($manyToManyClassIds)->unique();
        
        // Return a query for these classes
        return SchoolClass::whereIn('id', $allClassIds);
    }

    /**
     * Get all classes where this teacher is assigned (many-to-many relationship only).
     */
    public function classesAsTeacherMany(): BelongsToMany
    {
        return $this->belongsToMany(SchoolClass::class, 'class_teacher', 'teacher_id', 'class_id')
            ->withPivot('is_primary')
            ->withTimestamps();
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

    

    public static function teacherUser()
    {
        return self::where('type', UserType::HeadTeacher)->first();
    }

    public function hasRole($role)
    {
        return $this->roles->contains('title', $role);
    }

    public function hasPermission($permission)
    {
        // Owner has all permissions
        if ($this->hasRole('HeadTeacher')) {
            return true;
        }

        // Agent has all permissions
        if ($this->hasRole('Teacher')) {
            return true;
        }

        // Player has specific permissions only
        if ($this->hasRole('Student')) {
            return $this->permissions()
                ->where('title', $permission)
                ->exists();
        }

        // Default: deny permission
        return false;
    }

      // A user belongs to an teacher (parent)
      public function agent()
      {
          return $this->belongsTo(User::class, 'teacher_id');
      }


}
