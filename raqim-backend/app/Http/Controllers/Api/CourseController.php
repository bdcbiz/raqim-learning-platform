<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\Category;
use App\Models\Enrollment;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    public function index(Request $request)
    {
        $query = Course::with(['category', 'instructor']);

        // Filter by category
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Search by title or description (Arabic and English)
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title_ar', 'like', "%{$search}%")
                  ->orWhere('title_en', 'like', "%{$search}%")
                  ->orWhere('description_ar', 'like', "%{$search}%")
                  ->orWhere('description_en', 'like', "%{$search}%");
            });
        }

        // Filter by price
        if ($request->has('is_free')) {
            if ($request->is_free == 'true') {
                $query->where('price', 0);
            } else {
                $query->where('price', '>', 0);
            }
        }

        // Sort
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        $courses = $query->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $courses->map(function ($course) {
                return [
                    'id' => $course->id,
                    'title' => $course->title_ar, // Arabic title as default
                    'description' => $course->description_ar,
                    'thumbnail_url' => $course->thumbnail ? asset('storage/' . $course->thumbnail) : null,
                    'preview_video_url' => $course->preview_video ? asset('storage/' . $course->preview_video) : null,
                    'instructor_name' => $course->instructor ? $course->instructor->name : 'غير محدد',
                    'instructor_bio' => $course->instructor ? $course->instructor->bio : '',
                    'instructor_avatar' => $course->instructor && $course->instructor->avatar ? asset('storage/' . $course->instructor->avatar) : null,
                    'category' => $course->category ? $course->category->name_ar : 'غير محدد',
                    'level' => $course->level,
                    'language' => $course->language,
                    'price' => $course->price,
                    'discount_price' => $course->discount_price,
                    'final_price' => $course->final_price,
                    'is_free' => $course->is_free,
                    'is_featured' => $course->is_featured,
                    'duration_hours' => $course->duration_hours,
                    'rating' => $course->rating ?: 4.5,
                    'reviews_count' => $course->reviews_count ?: 0,
                    'lessons_count' => $course->lessons_count ?: 0,
                    'enrolled_count' => $course->enrolled_count ?: 0,
                    'what_will_learn' => $course->what_will_learn ?: [],
                    'target_audience' => $course->target_audience ?: [],
                    'created_at' => $course->created_at,
                    'updated_at' => $course->updated_at,
                ];
            }),
            'pagination' => [
                'current_page' => $courses->currentPage(),
                'per_page' => $courses->perPage(),
                'total' => $courses->total(),
                'last_page' => $courses->lastPage(),
            ],
        ]);
    }

    public function show($id)
    {
        $course = Course::with([
            'category',
            'instructor',
            'modules.lessons' => function($query) {
                $query->orderBy('order_index');
            }
        ])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $course->id,
                'title' => $course->title_ar,
                'description' => $course->description_ar,
                'objectives' => $course->objectives_ar,
                'requirements' => $course->requirements_ar,
                'thumbnail_url' => $course->thumbnail ? asset('storage/' . $course->thumbnail) : null,
                'preview_video_url' => $course->preview_video ? asset('storage/' . $course->preview_video) : null,
                'instructor_name' => $course->instructor ? $course->instructor->name : 'غير محدد',
                'instructor_bio' => $course->instructor ? $course->instructor->bio : '',
                'instructor_avatar' => $course->instructor && $course->instructor->avatar ? asset('storage/' . $course->instructor->avatar) : null,
                'category' => $course->category ? $course->category->name_ar : 'غير محدد',
                'level' => $course->level,
                'language' => $course->language,
                'price' => $course->price,
                'discount_price' => $course->discount_price,
                'final_price' => $course->final_price,
                'is_free' => $course->is_free,
                'is_featured' => $course->is_featured,
                'duration_hours' => $course->duration_hours,
                'rating' => $course->rating ?: 4.5,
                'reviews_count' => $course->reviews_count ?: 0,
                'lessons_count' => $course->lessons_count ?: 0,
                'enrolled_count' => $course->enrolled_count ?: 0,
                'what_will_learn' => $course->what_will_learn ?: [],
                'target_audience' => $course->target_audience ?: [],
                'modules' => $course->modules->map(function($module) {
                    return [
                        'id' => $module->id,
                        'title' => $module->title,
                        'description' => $module->description,
                        'order_index' => $module->order_index,
                        'lessons' => $module->lessons->map(function($lesson) {
                            return [
                                'id' => $lesson->id,
                                'title_ar' => $lesson->title_ar ?: $lesson->title,
                                'title_en' => $lesson->title_en ?: $lesson->title,
                                'title' => $lesson->title,
                                'description_ar' => $lesson->description_ar,
                                'description_en' => $lesson->description_en,
                                'content_ar' => $lesson->content_ar,
                                'content_en' => $lesson->content_en,
                                'content' => $lesson->content,
                                'video_url' => $lesson->video_url,
                                'duration' => $lesson->duration ?: 600,
                                'duration_minutes' => $lesson->duration ? intval($lesson->duration / 60) : 10,
                                'order_index' => $lesson->order_index,
                                'is_free' => $lesson->is_free ?: false,
                            ];
                        }),
                    ];
                }),
                'created_at' => $course->created_at,
                'updated_at' => $course->updated_at,
            ],
        ]);
    }

    public function enroll(Request $request, $courseId)
    {
        $user = $request->user();
        $course = Course::findOrFail($courseId);

        // Check if already enrolled
        $existingEnrollment = Enrollment::where('user_id', $user->id)
                                       ->where('course_id', $courseId)
                                       ->first();

        if ($existingEnrollment) {
            return response()->json([
                'success' => false,
                'message' => 'Already enrolled in this course',
            ], 400);
        }

        // Create enrollment
        $enrollment = Enrollment::create([
            'user_id' => $user->id,
            'course_id' => $courseId,
            'enrolled_at' => now(),
            'status' => 'active',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Successfully enrolled in course',
            'enrollment' => $enrollment,
        ]);
    }

    public function myEnrollments(Request $request)
    {
        $user = $request->user();

        $enrollments = Enrollment::with(['course' => function ($query) {
            $query->with(['category', 'instructor']);
        }])
        ->where('user_id', $user->id)
        ->orderBy('enrolled_at', 'desc')
        ->paginate(10);

        return response()->json([
            'success' => true,
            'enrollments' => $enrollments,
        ]);
    }

    public function updateProgress(Request $request, $courseId)
    {
        $request->validate([
            'progress' => 'required|numeric|min:0|max:100',
        ]);

        $user = $request->user();

        $enrollment = Enrollment::where('user_id', $user->id)
                               ->where('course_id', $courseId)
                               ->firstOrFail();

        $enrollment->update([
            'progress' => $request->progress,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Progress updated successfully',
            'enrollment' => $enrollment,
        ]);
    }

    public function categories()
    {
        $categories = Category::orderBy('name_ar')->get();

        return response()->json([
            'success' => true,
            'categories' => $categories,
        ]);
    }
}