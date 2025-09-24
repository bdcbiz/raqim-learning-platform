<?php

namespace App\Filament\Admin\Resources\News\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class NewsForm
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
                Textarea::make('excerpt_ar')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('excerpt_en')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('content_ar')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('content_en')
                    ->required()
                    ->columnSpanFull(),
                FileUpload::make('featured_image')
                    ->image()
                    ->required(),
                Textarea::make('gallery')
                    ->default(null)
                    ->columnSpanFull(),
                TextInput::make('author_id')
                    ->required()
                    ->numeric(),
                Select::make('category')
                    ->options([
            'announcement' => 'Announcement',
            'update' => 'Update',
            'event' => 'Event',
            'article' => 'Article',
            'tutorial' => 'Tutorial',
        ])
                    ->required(),
                Textarea::make('tags')
                    ->default(null)
                    ->columnSpanFull(),
                Toggle::make('is_featured')
                    ->required(),
                Toggle::make('is_published')
                    ->required(),
                TextInput::make('views_count')
                    ->required()
                    ->numeric()
                    ->default(0),
                DateTimePicker::make('published_at'),
            ]);
    }
}
