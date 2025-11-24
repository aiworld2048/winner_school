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
                'type' => $this->type,
                'roles' => $this->whenLoaded('roles', fn () => $this->roles->pluck('name')),
            ],
            'token' => $this->createToken($this->user_name ?? ('user-'.$this->id))->plainTextToken,
        ];
    }
}
