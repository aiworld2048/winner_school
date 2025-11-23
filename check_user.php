<?php

use App\Enums\UserType;
use App\Models\User;
use Illuminate\Contracts\Console\Kernel;

/*
|--------------------------------------------------------------------------
| User/Role Consistency Check
|--------------------------------------------------------------------------
| Quick helper script you can run with `php check_user.php`.
| It boots Laravel, loads every user with their assigned roles, and shows:
|   - current UserType label
|   - roles linked via `role_user`
|   - whether those roles match what the enum expects
| At the end it prints total users per type and highlights any mismatches.
*/

require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();

$users = User::with('roles')->orderBy('id')->get();

if ($users->isEmpty()) {
    echo "No users found.\n";
    exit(0);
}

$expectedRoleByType = [
    UserType::HeadTeacher->value => 'HeadTeacher',
    UserType::Teacher->value => 'Teacher',
    UserType::Student->value => 'Student',
    UserType::SystemWallet->value => 'SystemWallet',
];

$columnHeaders = [
    str_pad('ID', 5),
    str_pad('Username', 15),
    str_pad('UserType', 15),
    str_pad('Roles', 20),
    'Match',
];

echo implode(' | ', $columnHeaders) . PHP_EOL;
echo str_repeat('-', 70) . PHP_EOL;

$typeTotals = [];
$mismatches = 0;

foreach ($users as $user) {
    $typeTotals[$user->type] = ($typeTotals[$user->type] ?? 0) + 1;

    $roles = $user->roles->pluck('title')->toArray();
    $expectedRole = $expectedRoleByType[$user->type] ?? 'N/A';
    $hasExpectedRole = in_array($expectedRole, $roles, true);
    $matchLabel = $hasExpectedRole ? '✔' : '✖';

    if (!$hasExpectedRole) {
        $mismatches++;
    }

    printf(
        "%-5s | %-15s | %-15s | %-20s | %s\n",
        $user->id,
        $user->user_name,
        UserType::from($user->type)->label(),
        implode(', ', $roles) ?: '-',
        $matchLabel
    );
}

echo PHP_EOL . "Totals by UserType:" . PHP_EOL;
foreach (UserType::cases() as $typeCase) {
    $count = $typeTotals[$typeCase->value] ?? 0;
    echo sprintf("- %-15s : %d\n", $typeCase->label(), $count);
}

echo PHP_EOL;
if ($mismatches > 0) {
    echo "⚠ Found {$mismatches} user(s) without their expected role. Please run RoleUserTableSeeder or assign roles manually.\n";
    exit(1);
}

echo "All users have the expected role assignments.\n";
exit(0);

