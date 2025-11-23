<?php

namespace Database\Seeders;

use App\Enums\TransactionName;
use App\Enums\UserType;
use App\Models\User;
use App\Services\CustomWalletService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UsersTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $walletService = new CustomWalletService();

        // Create Owner
        $owner = $this->createUser(UserType::HeadTeacher, 'Head Teacher', 'head_teacher', '09123456789');
        $walletService->deposit($owner, 10 * 100_000, TransactionName::CapitalDeposit);

        // Create SystemWallet
        $systemWallet = $this->createUser(UserType::SystemWallet, 'System Wallet', 'system', '09999999999');
        $walletService->deposit($systemWallet, 5 * 100_000, TransactionName::CapitalDeposit);

        // Create Teacher under Owner
        $teacher = $this->createUser(UserType::Teacher, 'Teacher', 'T-11111', '09888888888', $owner->id);
        $walletService->deposit($teacher, 5 * 100_000, TransactionName::CapitalDeposit);

        // Create Students under Teacher
        $student_1 = $this->createUser(UserType::Student, 'Student 1', 'S-11111', '09511111111', $teacher->id);
        $walletService->transfer($teacher, $student_1, 30_000, TransactionName::CreditTransfer);
        
        $student_2 = $this->createUser(UserType::Student, 'Student 2', 'S-22222', '09522222222', $teacher->id);
        $walletService->transfer($teacher, $student_2, 30_000, TransactionName::CreditTransfer);
        
        $student_3 = $this->createUser(UserType::Student, 'Student 3', 'S-33333', '09533333333', $teacher->id);
        $walletService->transfer($teacher, $student_3, 30_000, TransactionName::CreditTransfer);
        
        $student_4 = $this->createUser(UserType::Student, 'Student 4', 'S-44444', '09544444444', $teacher->id);
        $walletService->transfer($teacher, $student_4, 30_000, TransactionName::CreditTransfer);
        
        $student_5 = $this->createUser(UserType::Student, 'Student 5', 'S-55555', '09555555555', $teacher->id);
        $walletService->transfer($teacher, $student_5, 30_000, TransactionName::CreditTransfer);
    }

    private function createUser(UserType $type, $name, $user_name, $phone, $parent_id = null)
    {
        return User::create([
            'name' => $name,
            'user_name' => $user_name,
            'phone' => $phone,
            'password' => Hash::make('winnerschool'),
            'teacher_id' => $parent_id,
            'status' => 1,
            'is_changed_password' => 1,
            'type' => $type->value,
        ]);
    }
}
