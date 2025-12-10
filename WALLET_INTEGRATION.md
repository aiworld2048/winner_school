# Wallet Integration for Flutter App

## Overview
This document describes the wallet system integration for the Flutter mobile app (`school_apk`).

## API Endpoints Used

### 1. Get Banks/Payment Types for Deposit
- **Endpoint**: `GET /api/banks`
- **Authentication**: Required (Bearer token)
- **Response Structure**:
```json
{
  "status": "Request was successful.",
  "message": "Payment Type list successfule",
  "data": [
    {
      "id": 3,
      "name": "Myo Khaing",
      "no": "09257031942",
      "bank_id": 6,
      "bank_name": "KBZ Pay",
      "img": "https://lion11.site/assets/img/paymentType/kpay.png"
    }
  ]
}
```

### 2. Submit Deposit Request
- **Endpoint**: `POST /api/depositfinicial`
- **Authentication**: Required (Bearer token)
- **Request Body**:
  - `agent_payment_type_id` (integer, required): Bank account ID from `/banks` endpoint
  - `amount` (integer, required, min: 1000): Deposit amount in MMK
  - `refrence_no` (string, required, 6 digits): Receipt reference number
  - `image` (file, optional): Deposit slip image
- **Response Structure**:
```json
{
  "status": "Request was successful.",
  "message": "Deposit Request Success",
  "data": {
    "id": 4,
    "agent_payment_type_id": "1",
    "user_id": 17,
    "teacher_id": 2,
    "amount": "10000",
    "refrence_no": "123456",
    "created_at": "2025-12-10T05:13:03.000000Z",
    "updated_at": "2025-12-10T05:13:03.000000Z"
  }
}
```

### 3. Submit Withdraw Request
- **Endpoint**: `POST /api/withdrawfinicial`
- **Authentication**: Required (Bearer token)
- **Request Body**:
  - `payment_type_id` (integer, required): Payment type ID
  - `amount` (integer, required, min: 10000): Withdraw amount in MMK
  - `account_name` (string, required): Account holder name
  - `account_number` (string, required, numeric): Account number
  - `password` (string, required): User password for verification
- **Response Structure**:
```json
{
  "status": "Request was successful.",
  "message": "Withdraw Request Success",
  "data": {
    "id": 1,
    "user_id": 17,
    "agent_id": 2,
    "amount": "10000",
    "account_name": "John Doe",
    "account_number": "1234567890",
    "payment_type_id": 1,
    "created_at": "2025-12-10T05:13:03.000000Z",
    "updated_at": "2025-12-10T05:13:03.000000Z"
  }
}
```

### 4. Get Deposit Logs
- **Endpoint**: `GET /api/depositlogfinicial`
- **Authentication**: Required (Bearer token)

### 5. Get Withdraw Logs
- **Endpoint**: `GET /api/withdrawlogfinicial`
- **Authentication**: Required (Bearer token)

## Implementation Details

### Files Modified/Created

1. **`school_apk/lib/features/student/models/wallet_models.dart`** (NEW)
   - Created models for `BankAccount`, `DepositRequest`, and `WithdrawRequest`
   - Provides type-safe data structures for wallet operations

2. **`school_apk/lib/features/student/data/wallet_repository.dart`** (UPDATED)
   - Fixed `fetchBanks()` method to properly call the API
   - Already supports image upload via `MultipartFile` parameter

3. **`school_apk/lib/features/student/presentation/screens/student_wallet_screen.dart`** (UPDATED)
   - Added image picker functionality for deposit slips
   - Updated deposit handler to include image upload
   - Uses correct API response field names:
     - `bank['id']` - Bank account ID (used as `agent_payment_type_id`)
     - `bank['name']` - Account holder name
     - `bank['no']` - Account number
     - `bank['bank_name']` - Payment type name (e.g., "KBZ Pay")
     - `bank['img']` - Bank/payment type image URL

4. **`school_apk/pubspec.yaml`** (UPDATED)
   - Added `image_picker: ^1.0.7` dependency for selecting deposit slip images

### Features Implemented

✅ **Deposit Functionality**
- Fetch available bank accounts for deposit
- Display bank account information with images
- Copy account number to clipboard
- Enter deposit amount (minimum 1000 MMK)
- Enter 6-digit reference number
- Upload deposit slip image (optional)
- Submit deposit request

✅ **Withdraw Functionality**
- Select payment type
- Enter account details (name, number)
- Enter withdraw amount (minimum 10000 MMK)
- Enter password for verification
- Submit withdraw request

✅ **Transaction History**
- View deposit logs
- View withdraw logs

✅ **Wallet Balance**
- Display current wallet balance from user profile

## Usage

### Deposit Flow
1. User opens wallet screen
2. System fetches available banks from `/api/banks`
3. User selects a bank account
4. User enters amount (min 1000 MMK)
5. User enters 6-digit reference number
6. User optionally uploads deposit slip image
7. User submits deposit request
8. System calls `/api/depositfinicial` with form data
9. On success, user balance is refreshed and deposit log is updated

### Withdraw Flow
1. User opens wallet screen
2. System fetches payment types from `/api/paymentTypefinicial`
3. User selects payment type
4. User enters account name and number
5. User enters withdraw amount (min 10000 MMK)
6. User enters password
7. User submits withdraw request
8. System calls `/api/withdrawfinicial`
9. On success, user balance is refreshed and withdraw log is updated

## Validation Rules

### Deposit
- Amount: Minimum 1000 MMK
- Reference number: Exactly 6 digits, numeric only
- Bank selection: Required

### Withdraw
- Amount: Minimum 10000 MMK
- Account name: Required, non-empty
- Account number: Required, numeric only
- Password: Required, must match user's password
- Payment type: Required

## Error Handling

- Network errors are caught and displayed to the user
- Validation errors are shown before submission
- API error messages are displayed from server response
- Image picker errors are handled gracefully

## Dependencies

- `dio: ^5.7.0` - HTTP client (already included)
- `image_picker: ^1.0.7` - Image selection (newly added)
- `flutter_riverpod: ^2.5.1` - State management (already included)

## Next Steps

1. Run `flutter pub get` to install the new `image_picker` dependency
2. For Android: Add camera/gallery permissions in `AndroidManifest.xml` if not already present
3. For iOS: Add camera/gallery permissions in `Info.plist` if not already present
4. Test the deposit and withdraw flows
5. Verify image upload functionality

## Notes

- The deposit uses `bank['id']` as the `agent_payment_type_id` in the API request
- Image upload is optional for deposits
- All amounts are in MMK (Myanmar Kyat)
- The wallet balance is automatically refreshed after successful transactions

