<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'user' => [
                'id' => $this->id,
                'name' => $this->name,
                'user_name' => $this->user_name,
                'phone' => $this->phone,
                'email' => $this->email,
                'balance' => $this->balance,
                'status' => $this->status,
                'type' => (int) $this->type,
                'class_id' => $this->class_id,
                'subject_id' => $this->subject_id,
                'academic_year_id' => $this->academic_year_id,
                'referral_code' => $this->referral_code,
                'role_id' => optional($this->roles->first())->id,
                'roles' => $this->whenLoaded('roles', function () {
                    return $this->roles->pluck('name')->filter()->values();
                }),
            ],
            'token' => $this->createToken($this->user_name ?? ('user-'.$this->id))->plainTextToken,
        ];
    }
}
