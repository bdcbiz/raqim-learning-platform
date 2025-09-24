<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Course extends Model
{
    use HasFactory;

    protected $fillable = [
        'title_ar',
        'title_en',
        'slug',
        'description_ar',
        'description_en',
        'objectives_ar',
        'objectives_en',
        'requirements_ar',
        'requirements_en',
        'thumbnail',
        'preview_video',
        'instructor_id',
        'category_id',
        'level',
        'language',
        'duration_hours',
        'price',
        'discount_price',
        'is_free',
        'is_featured',
        'status',
        'enrolled_count',
        'rating',
        'reviews_count',
        'lessons_count',
        'what_will_learn',
        'target_audience',
        'published_at'
    ];

    protected $casts = [
        'is_free' => 'boolean',
        'is_featured' => 'boolean',
        'price' => 'decimal:2',
        'discount_price' => 'decimal:2',
        'rating' => 'decimal:2',
        'what_will_learn' => 'array',
        'target_audience' => 'array',
        'published_at' => 'datetime',
    ];

    public static function booted()
    {
        static::creating(function ($course) {
            if (empty($course->slug)) {
                $course->slug = Str::slug($course->title_en);
            }
        });
    }

    public function instructor()
    {
        return $this->belongsTo(User::class, 'instructor_id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function enrollments()
    {
        return $this->hasMany(Enrollment::class);
    }

    public function students()
    {
        return $this->belongsToMany(User::class, 'enrollments')
            ->withPivot('progress', 'status', 'enrolled_at', 'completed_at');
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function getTitleAttribute()
    {
        return app()->getLocale() == 'ar' ? $this->title_ar : $this->title_en;
    }

    public function getDescriptionAttribute()
    {
        return app()->getLocale() == 'ar' ? $this->description_ar : $this->description_en;
    }

    public function getFinalPriceAttribute()
    {
        if ($this->is_free) {
            return 0;
        }
        return $this->discount_price ?? $this->price;
    }
}