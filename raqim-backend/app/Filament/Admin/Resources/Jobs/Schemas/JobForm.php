<?php

namespace App\Filament\Admin\Resources\Jobs\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class JobForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('title_ar')
                    ->required(),
                TextInput::make('title_en')
                    ->required(),
                TextInput::make('company_name')
                    ->required(),
                TextInput::make('company_logo')
                    ->default(null),
                Textarea::make('description_ar')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('description_en')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('requirements_ar')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('requirements_en')
                    ->required()
                    ->columnSpanFull(),
                Select::make('type')
                    ->options([
            'full_time' => 'Full time',
            'part_time' => 'Part time',
            'contract' => 'Contract',
            'internship' => 'Internship',
            'freelance' => 'Freelance',
        ])
                    ->required(),
                Select::make('location_type')
                    ->options(['onsite' => 'Onsite', 'remote' => 'Remote', 'hybrid' => 'Hybrid'])
                    ->required(),
                TextInput::make('location')
                    ->required(),
                TextInput::make('salary_range')
                    ->default(null),
                TextInput::make('experience_level')
                    ->required(),
                Textarea::make('skills')
                    ->default(null)
                    ->columnSpanFull(),
                TextInput::make('application_link')
                    ->default(null),
                TextInput::make('contact_email')
                    ->email()
                    ->required(),
                Toggle::make('is_active')
                    ->required(),
                Toggle::make('is_featured')
                    ->required(),
                TextInput::make('views_count')
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('applications_count')
                    ->required()
                    ->numeric()
                    ->default(0),
                DateTimePicker::make('deadline'),
            ]);
    }
}
