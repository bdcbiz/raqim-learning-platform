<?php

namespace App\Filament\Admin\Resources\Jobs\Pages;

use App\Filament\Admin\Resources\Jobs\JobResource;
use Filament\Resources\Pages\CreateRecord;

class CreateJob extends CreateRecord
{
    protected static string $resource = JobResource::class;
}
