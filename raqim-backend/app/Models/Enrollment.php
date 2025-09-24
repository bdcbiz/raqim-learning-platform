<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Enrollment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'course_id',
        'status',
        'progress',
        'completed_lessons',
        'enrolled_at',
        'completed_at',
        'last_accessed_at',
        'certificate_issued',
        'certificate_number',
        'certificate_issued_at',
        'lesson_progress'
    ];

    protected $casts = [
        'progress' => 'decimal:2',
        'certificate_issued' => 'boolean',
        'enrolled_at' => 'datetime',
        'completed_at' => 'datetime',
        'last_accessed_at' => 'datetime',
        'certificate_issued_at' => 'datetime',
        'lesson_progress' => 'array'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function isCompleted()
    {
        return $this->status === 'completed';
    }

    public function isActive()
    {
        return $this->status === 'active';
    }
}