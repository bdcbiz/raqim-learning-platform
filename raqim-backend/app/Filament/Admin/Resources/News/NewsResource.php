<?php

namespace App\Filament\Admin\Resources\News;

use App\Filament\Admin\Resources\News\Pages\CreateNews;
use App\Filament\Admin\Resources\News\Pages\EditNews;
use App\Filament\Admin\Resources\News\Pages\ListNews;
use App\Filament\Admin\Resources\News\Schemas\NewsForm;
use App\Filament\Admin\Resources\News\Tables\NewsTable;
use App\Models\News;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class NewsResource extends Resource
{
    protected static ?string $model = News::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-newspaper';

    protected static ?string $navigationLabel = 'الأخبار';

    protected static ?string $pluralModelLabel = 'الأخبار';

    protected static ?string $modelLabel = 'خبر';

    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return NewsForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return NewsTable::configure($table);
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
            'index' => ListNews::route('/'),
            'create' => CreateNews::route('/create'),
            'edit' => EditNews::route('/{record}/edit'),
        ];
    }
}
