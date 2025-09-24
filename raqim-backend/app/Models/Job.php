<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Job extends Model
{
    use HasFactory;

    protected $fillable = [
        'title_ar',
        'title_en',
        'company_name',
        'company_logo',
        'description_ar',
        'description_en',
        'requirements_ar',
        'requirements_en',
        'type',
        'location_type',
        'location',
        'salary_range',
        'experience_level',
        'skills',
        'application_link',
        'contact_email',
        'is_active',
        'is_featured',
        'views_count',
        'applications_count',
        'deadline'
    ];

    protected $casts = [
        'skills' => 'array',
        'is_active' => 'boolean',
        'is_featured' => 'boolean',
        'deadline' => 'datetime'
    ];

    public function getTitleAttribute()
    {
        return app()->getLocale() == 'ar' ? $this->title_ar : $this->title_en;
    }

    public function getDescriptionAttribute()
    {
        return app()->getLocale() == 'ar' ? $this->description_ar : $this->description_en;
    }

    public function getRequirementsAttribute()
    {
        return app()->getLocale() == 'ar' ? $this->requirements_ar : $this->requirements_en;
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where(function($q) {
                $q->whereNull('deadline')
                  ->orWhere('deadline', '>=', now());
            });
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }
}