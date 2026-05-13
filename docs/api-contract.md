# GYMME API CONTRACT

## Authentication Flow

### Register Member

INPUT:
- user_full_name
- user_email_address
- user_password

PROCESS:
1. Create Firebase Auth user
2. Create user_accounts_global document
3. Set role = Member

OUTPUT:
- Success register
- Redirect to member dashboard

---

### Register Owner

INPUT:
- user_full_name
- user_email_address
- user_password
- gt_name_title
- gt_address_location

PROCESS:
1. Create Firebase Auth user
2. Create user_accounts_global
3. Create gym_tenants
4. Generate default ranks

OUTPUT:
- Success register
- Redirect to owner dashboard

---

### Login

INPUT:
- email
- password

PROCESS:
1. Firebase Auth login
2. Fetch role from user_accounts_global

OUTPUT:
- Owner → Admin Dashboard
- Member → Member Dashboard

---

# Equipment CRUD Contract

## Create Equipment

INPUT:
- equip_name_label
- equip_usage_instruction_text
- equip_tutorial_video_link

OUTPUT:
- Equipment document created

---

## Update Equipment

INPUT:
- equipment ID
- updated data

OUTPUT:
- Updated equipment

---

## Delete Equipment

INPUT:
- equipment ID

OUTPUT:
- Equipment removed

---

# QR Check-in Contract

## Generate QR

INPUT:
- mem_user_uid
- mem_gym_id

OUTPUT:
- Dynamic QR

---

## Scan QR

PROCESS:
1. Validate member
2. Validate gym
3. Validate active membership
4. Create attendance log
5. Update points

OUTPUT:
- Success check-in
- Error validation

---

# Gamification Contract

## Rank Progress

INPUT:
- member points

PROCESS:
- Compare with gym_master_ranks

OUTPUT:
- Current rank
- Next rank progress

---

# Error Response Standard

## Firebase Auth Error
- invalid-email
- email-already-in-use
- weak-password

## Firestore Error
- permission-denied
- unavailable
- network-error

---

# Response Pattern

Success:
{
  success: true,
  message: "Operation successful"
}

Error:
{
  success: false,
  message: "Operation failed"
}

# Gym Access Flow Contract

## Initial User State

After registration:
- user does NOT automatically become gym member
- user enters gym discovery flow

---

# Membership Access Flow

INPUT:
- selected gym
- membership package

PROCESS:
1. Create gym_members_registry document
2. Activate membership
3. Enable member features

OUTPUT:
- Member dashboard unlocked

---

# Daily Access Flow

INPUT:
- selected gym
- daily pass

PROCESS:
1. Create gym_daily_visits document
2. Allow temporary gym access

OUTPUT:
- Limited dashboard access

---

# Feature Access Rules

## Membership User
Can access:
- QR Membership
- Streak
- Points
- Rank
- Attendance history
- Loyalty features

## Daily Visitor
Can access:
- Daily check-in
- Basic gym access

Cannot access:
- loyalty
- streak
- membership QR
- rank system