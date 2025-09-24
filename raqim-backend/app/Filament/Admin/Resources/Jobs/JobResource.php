<?php

namespace App\Filament\Admin\Resources\Jobs;

use App\Filament\Admin\Resources\Jobs\Pages\CreateJob;
use App\Filament\Admin\Resources\Jobs\Pages\EditJob;
use App\Filament\Admin\Resources\Jobs\Pages\ListJobs;
use App\Filament\Admin\Resources\Jobs\Schemas\JobForm;
use App\Filament\Admin\Resources\Jobs\Tables\JobsTable;
use App\Models\Job;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class JobResource extends Resource
{
    protected static ?string $model = Job::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-briefcase';

    protected static ?string $navigationLabel = 'الوظائف';

    protected static ?string $pluralModelLabel = 'الوظائف';

    protected static ?string $modelLabel = 'وظيفة';

    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return JobForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return JobsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListJobs::route('/'),
            'create' => CreateJob::route('/create'),
            'edit' => EditJob::route('/{record}/edit'),
        ];
    }
}
