<?php

namespace App\Filament\Admin\Resources\Jobs\Pages;

use App\Filament\Admin\Resources\Jobs\JobResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditJob extends EditRecord
{
    protected static string $resource = JobResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
