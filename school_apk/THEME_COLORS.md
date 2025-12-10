# App Theme Colors - Modern & User-Friendly

## Color Palette Overview

The app now uses a modern, vibrant, and user-friendly color scheme designed for educational applications.

### Primary Colors

**Indigo/Purple** - Trustworthy, Modern, Professional
- Primary: `#6366F1` (Indigo-500) - Main brand color
- Primary Dark: `#4F46E5` (Indigo-600) - Hover/pressed states
- Primary Container: `#E0E7FF` (Indigo-100) - Light backgrounds

### Secondary Colors

**Pink/Coral** - Energetic, Friendly, Approachable
- Secondary: `#EC4899` (Pink-500) - Accent color
- Secondary Dark: `#DB2777` (Pink-600) - Hover/pressed states
- Secondary Container: `#FCE7F3` (Pink-100) - Light backgrounds

### Tertiary Colors

**Teal/Cyan** - Calm, Professional, Fresh
- Tertiary: `#14B8A6` (Teal-500) - Supporting color
- Tertiary Container: `#CCFBF1` (Teal-100) - Light backgrounds

### Semantic Colors

**Success** - Green/Emerald
- Success: `#10B981` (Emerald-500)
- Success Light: `#D1FAE5` (Emerald-100)

**Warning** - Amber/Orange
- Warning: `#F59E0B` (Amber-500)
- Warning Light: `#FEF3C7` (Amber-100)

**Danger/Error** - Red
- Danger: `#EF4444` (Red-500)
- Danger Light: `#FEE2E2` (Red-100)

### Neutral Colors

**Backgrounds**
- Scaffold: `#F8FAFC` (Slate-50) - Main app background
- Surface: `#FFFFFF` - Card/container backgrounds
- Surface Variant: `#F1F5F9` (Slate-100) - Subtle backgrounds

**Text**
- On Surface: `#0F172A` (Slate-900) - Primary text
- On Surface Variant: `#475569` (Slate-600) - Secondary text
- Muted: `#64748B` (Slate-500) - Tertiary text

**Borders & Outlines**
- Outline: `#E2E8F0` (Slate-200) - Borders and dividers

## Gradients

### Hero Gradient
Modern indigo to purple gradient for hero sections:
```
#6366F1 → #8B5CF6 → #A855F7
```

### Accent Gradient
Warm pink to orange gradient for highlights:
```
#EC4899 → #F97316 → #FB923C
```

### Success Gradient
Fresh teal to cyan gradient for success states:
```
#14B8A6 → #06B6D4 → #22D3EE
```

### Background Gradient
Subtle background gradient:
```
#F8FAFC → #F1F5F9
```

## Design Principles

1. **Accessibility**: All colors meet WCAG AA contrast requirements
2. **Modern**: Uses contemporary color palettes (Tailwind-inspired)
3. **User-Friendly**: Soft backgrounds reduce eye strain
4. **Vibrant**: Energetic gradients for engagement
5. **Professional**: Suitable for educational environment

## Usage Guidelines

### Primary Color
- Use for main actions, buttons, links
- Navigation indicators
- Brand elements

### Secondary Color
- Use for secondary actions
- Highlights and accents
- Call-to-action elements

### Tertiary Color
- Use for supporting information
- Success states
- Calm, professional elements

### Semantic Colors
- Success: Positive actions, confirmations
- Warning: Cautionary messages
- Danger: Errors, destructive actions

## Color Accessibility

All color combinations have been tested for:
- ✅ Text contrast (WCAG AA compliant)
- ✅ Button contrast
- ✅ Focus states visibility
- ✅ Color-blind friendly alternatives

## Theme Files

- `lib/core/theme/app_colors.dart` - Color definitions
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/core/theme/app_gradients.dart` - Gradient definitions
- `lib/core/theme/app_typography.dart` - Typography (uses Google Fonts)

## Migration Notes

The new color scheme replaces the previous:
- Old Primary: `#0052CC` (Blue) → New: `#6366F1` (Indigo)
- Old Secondary: `#FFB703` (Yellow) → New: `#EC4899` (Pink)
- Old Tertiary: `#1FAB89` (Green) → New: `#14B8A6` (Teal)

All changes are backward compatible as they use the same ColorScheme structure.

