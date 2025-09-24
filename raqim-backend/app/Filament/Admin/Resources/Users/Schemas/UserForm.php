<?php

namespace App\Filament\Admin\Resources\Users\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->required(),
                TextInput::make('email')
                    ->label('Email address')
                    ->email()
                    ->required(),
                DateTimePicker::make('email_verified_at'),
                TextInput::make('password')
                    ->password()
                    ->required(),
                TextInput::make('phone')
                    ->tel()
                    ->default(null),
                Select::make('role')
                    ->options(['admin' => 'Admin', 'instructor' => 'Instructor', 'student' => 'Student'])
                    ->default('student')
                    ->required(),
                TextInput::make('avatar')
                    ->default(null),
                Textarea::make('bio')
                    ->default(null)
                    ->columnSpanFull(),
                Textarea::make('skills')
                    ->default(null)
                    ->columnSpanFull(),
                TextInput::make('country')
                    ->default(null),
                TextInput::make('city')
                    ->default(null),
                DatePicker::make('birth_date'),
                Select::make('status')
                    ->options(['active' => 'Active', 'inactive' => 'Inactive', 'banned' => 'Banned'])
                    ->default('active')
                    ->required(),
            ]);
    }
}
