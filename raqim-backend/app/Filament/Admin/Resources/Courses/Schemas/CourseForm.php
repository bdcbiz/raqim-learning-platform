<?php

namespace App\Filament\Admin\Resources\Courses\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class CourseForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('title_ar')
                    ->required(),
                TextInput::make('title_en')
                    ->required(),
                TextInput::make('slug')
                    ->required(),
                Textarea::make('description_ar')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('description_en')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('objectives_ar')
                    ->default(null)
                    ->columnSpanFull(),
                Textarea::make('objectives_en')
                    ->default(null)
                    ->columnSpanFull(),
                Textarea::make('requirements_ar')
                    ->default(null)
                    ->columnSpanFull(),
                Textarea::make('requirements_en')
                    ->default(null)
                    ->columnSpanFull(),
                TextInput::make('thumbnail')
                    ->required(),
                TextInput::make('preview_video')
                    ->default(null),
                TextInput::make('instructor_id')
                    ->required()
                    ->numeric(),
                TextInput::make('category_id')
                    ->required()
                    ->numeric(),
                Select::make('level')
                    ->options(['beginner' => 'Beginner', 'intermediate' => 'Intermediate', 'advanced' => 'Advanced'])
                    ->required(),
                TextInput::make('language')
                    ->required()
                    ->default('ar'),
                TextInput::make('duration_hours')
                    ->required()
                    ->numeric(),
                TextInput::make('price')
                    ->required()
                    ->numeric()
                    ->prefix('$'),
                TextInput::make('discount_price')
                    ->numeric()
                    ->default(null),
                Toggle::make('is_free')
                    ->required(),
                Toggle::make('is_featured')
                    ->required(),
                Select::make('status')
                    ->options([
            'draft' => 'Draft',
            'pending' => 'Pending',
            'published' => 'Published',
            'archived' => 'Archived',
        ])
                    ->default('draft')
                    ->required(),
                TextInput::make('enrolled_count')
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('rating')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                TextInput::make('reviews_count')
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('lessons_count')
                    ->required()
                    ->numeric()
                    ->default(0),
                Textarea::make('what_will_learn')
                    ->default(null)
                    ->columnSpanFull(),
                Textarea::make('target_audience')
                    ->default(null)
                    ->columnSpanFull(),
                DateTimePicker::make('published_at'),
            ]);
    }
}
