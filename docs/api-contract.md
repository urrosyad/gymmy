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