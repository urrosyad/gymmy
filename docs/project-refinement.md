# MEMBERSHIP FLOW REFINEMENT

## Critical Product Change

Users should NOT automatically become gym members after registration.

Registration only creates:
- Firebase Auth account
- global user profile

Users must manually:
- discover gym
- choose access type
- activate membership or daily visit

---

# Initial User State

After first login:
- user has no gym
- dashboard should show onboarding state

---

# Onboarding State Requirements

If user has no active gym:
show:
- gym discovery CTA
- join membership CTA
- daily access CTA

Hide:
- streak system
- points
- rank progress
- member QR
- attendance analytics

---

# Membership Unlock Logic

Full dashboard features only unlock when:
- membership exists
AND
- membership status is active

---

# Daily Visitor Restrictions

Daily visitors should experience:
- limited dashboard
- temporary access
- no gamification

Avoid fake membership simulation.

---

# UX Requirements

The onboarding flow should feel:
- realistic
- understandable
- premium
- guided

Avoid:
- confusing feature locks
- aggressive upselling
- crowded onboarding screens