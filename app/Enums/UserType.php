<?php

namespace App\Enums;

enum UserType: int
{
    case HeadTeacher = 10;
    case Teacher = 15;
    case Student = 20;
    case SystemWallet = 30;

    public static function usernameLength(UserType $type): int
    {
        return match ($type) {
            self::HeadTeacher => 1,
            self::Teacher => 2,
            self::Student => 3,
            self::SystemWallet => 4,
        };
    }

    public static function childUserType(UserType $type): UserType
    {
        return match ($type) {
            self::HeadTeacher => self::Teacher,
            self::Teacher => self::Student,
            self::Student => self::Student,
            self::SystemWallet => self::SystemWallet,
        };
    }

    public static function canHaveChild(UserType $parent, UserType $child): bool
    {
        return match ($parent) {
            self::HeadTeacher => in_array($child, [self::Teacher, self::Student], true),
            self::Teacher => $child === self::Student,
            self::Student => false,
            self::SystemWallet => false,
        };
    }

    public function label(): string
    {
        return match ($this) {
            self::HeadTeacher => 'Head Teacher',
            self::Teacher => 'Teacher',
            self::Student => 'Student',
            self::SystemWallet => 'System Wallet',
        };
    }
}
