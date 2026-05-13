# GYMME DESIGN SYSTEM

## Design Direction

Style:
- Minimalist
- Modern
- Sporty
- Clean
- Soft Neon

# Anti AI-Slop Design Principles

GYMME MUST avoid generic AI-generated mobile UI patterns.

Avoid:
- excessive gradients
- glowing borders
- floating random shapes
- oversized rounded corners
- emoji usage
- overuse of glassmorphism
- colorful dashboards
- noisy spacing
- inconsistent icon sizes
- oversized typography
- excessive animations
- duplicated card patterns

The application should feel:
- grounded
- realistic
- premium
- calm
- structured
- modern SaaS-like
- fitness-tech professional

Design inspiration:
- Linear
- Notion
- Stripe Dashboard
- Apple Fitness
- Nike Training Club
- Fitbit

---

# Color Palette

| Usage | Hex |
|---|---|
| Primary | #C0FE39 |
| Secondary | #57B2DC |
| Accent | #BBF6E2 |
| Dark Background | #121417 |
| Card Surface | #1E2126 |

# Color Usage Rules

Primary lime color must only be used for:
- CTA buttons
- active indicators
- progress highlights
- important status

Avoid excessive lime usage across large surfaces.

Most surfaces should remain:
- dark neutral
- low saturation
- clean contrast

Avoid:
- rainbow color combinations
- random gradients
- bright dashboard cards

---

# Typography

## Headings
- Font: Montserrat
- Weight: Bold

## Body Text
- Font: Inter
- Weight: Regular / Medium

# Typography Rules

Avoid oversized headings.

Use:
- compact spacing
- medium typography scale
- high readability

Preferred hierarchy:
- H1 → 28
- H2 → 22
- H3 → 18
- Body → 14-16

Avoid:
- giant hero text
- excessive bolding
- decorative typography
---

# Dark Mode

## Background
#121417

## Surface
#1E2126

## Primary Text
#F1F3F4

## Secondary Text
#ADB5BD

---

# Core Components

## GymmeButton

Style:
- Stadium shape
- Lime background
- Bold text
- Haptic feedback

---

## GymmeCard

Style:
- Radius 16
- Soft border
- Minimal shadow

---

## GymmeInput

Style:
- Filled input
- Bottom border
- Active border blue
- Error text red

---

# Authentication UI

## Login Screen
- Universal login
- Dark mode premium style

## Register Screen
- Toggle:
  - Member
  - Owner Gym

## Validation
- Real-time validation
- Password strength meter

---

# Dashboard UI

## Owner Dashboard
Features:
- Member management
- Equipment CRUD
- Pricing management

## Member Dashboard
Features:
- Gym discovery
- QR membership
- Loyalty progress

---

# QR Experience

## Member Side
- Dynamic QR
- Auto refresh 60s

## Admin Side
- QR Scanner
- Bottom sheet validation

---

# Activity Logs UI

## Daily Check-in
- Calendar icon
- Timestamp

## Class Check-in
- Class icon
- Instructor label

## Animation
- AnimatedList fade-in

---

# Data Visualization

## Streak Chart
- 7-day attendance graph
- Use fl_chart

---

# Animation System

## Lottie Files
- success_checkin.json
- loading_bar.json
- rank_up_confetti.json

---

# Hero Animation Targets

- Equipment image
- Gym logo

---

# Iconography

Package:
- lucide_icons

Style:
- Thin
- Minimal
- Modern

# Spacing System

Use consistent 8-point spacing system.

Spacing scale:
- 4
- 8
- 12
- 16
- 24
- 32

Avoid:
- random paddings
- inconsistent margins
- crowded layouts

All screens should prioritize breathing room and alignment consistency.

# Card Design Rules

Cards should:
- use subtle contrast
- avoid excessive shadows
- avoid neon outlines
- maintain consistent padding

Preferred:
- radius 12-16
- flat modern surfaces
- soft border

Avoid:
- glowing cards
- floating 3D effects
- colorful cards everywhere

# Iconography Rules

Icons must:
- use consistent stroke width
- remain monochrome when possible
- use minimal styling

Avoid:
- emoji icons
- colorful icons
- mixed icon packs
- filled cartoon icons

Preferred:
- Lucide
- Phosphor
- Material Symbols Rounded

# Animation Philosophy

Animations should be subtle and purposeful.

Use animations only for:
- state transitions
- loading feedback
- navigation polish
- achievement feedback

Avoid:
- bouncing animations
- flashy transitions
- excessive motion
- distracting Lottie loops

Animation duration:
- 150ms to 300ms preferred

# Microcopy Guidelines

Text inside the application must be:
- concise
- professional
- calm
- non-gimmicky

Avoid:
- motivational spam
- emoji usage
- excessive excitement
- childish wording

Preferred tone:
- fitness-tech professional
- modern SaaS
- straightforward

Example:

GOOD:
"Check-in successful"

BAD:
"🔥 Awesome! You're crushing it today!"

# Dashboard Composition Rules

Dashboard must prioritize:
1. clarity
2. hierarchy
3. actionable information

Avoid:
- too many cards
- information overload
- multiple accent colors
- crowded statistics

Preferred layout:
- top summary
- primary CTA
- recent activity
- lightweight analytics

# UI Consistency Rules

All screens must maintain:
- identical spacing rhythm
- consistent button height
- consistent border radius
- consistent typography scale

Avoid:
- redesigning components per screen
- changing interaction patterns
- inconsistent navigation behavior

# AI GENERATION RESTRICTIONS

When generating UI:
- prioritize simplicity over creativity
- prioritize usability over visual gimmicks
- avoid trendy Dribbble-style layouts
- avoid overdesigned screens
- avoid startup landing-page aesthetics

GYMME should feel like:
a real scalable fitness SaaS product,
not an AI-generated concept app.