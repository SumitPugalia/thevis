# Brand Theme & Design System
## thevis.ai

**Version:** 1.0  
**Date:** 2024  
**Purpose:** Ensure consistent branding, UI/UX, and design across all thevis.ai interfaces

---

## 1. Brand Identity

### 1.1 Brand Positioning

**thevis.ai** is a professional, data-driven AI visibility optimization platform that helps companies improve their presence in AI systems.

**Brand Personality:**
- **Professional** - Trustworthy, expert, enterprise-ready
- **Modern** - Cutting-edge, innovative, forward-thinking
- **Data-Driven** - Analytical, precise, measurable
- **Efficient** - Streamlined, automated, scalable
- **Transparent** - Clear, honest, straightforward

### 1.2 Brand Values

1. **Clarity** - Clear communication, transparent metrics, understandable results
2. **Precision** - Accurate measurements, data-driven decisions, reliable automation
3. **Innovation** - Cutting-edge technology, AI-first approach, continuous improvement
4. **Trust** - Reliable service, consistent delivery, professional expertise
5. **Efficiency** - Automated workflows, streamlined processes, scalable solutions

### 1.3 Target Audience

**Primary Users:**
- **Consultants** - Internal/partner consultants managing multiple clients
- **Clients** - Product-based companies (new launches, existing products) and service-based companies

**User Characteristics:**
- Business-focused, results-oriented
- Value data and metrics
- Need professional, enterprise-grade tools
- Appreciate automation and efficiency
- Require clear, actionable insights

---

## 2. Color Palette

### 2.1 Primary Colors

**Primary Blue** - Trust, professionalism, technology
- `--color-primary-50`: `#EFF6FF` (Lightest)
- `--color-primary-100`: `#DBEAFE`
- `--color-primary-200`: `#BFDBFE`
- `--color-primary-300`: `#93C5FD`
- `--color-primary-400`: `#60A5FA`
- `--color-primary-500`: `#3B82F6` ⭐ **Main Primary**
- `--color-primary-600`: `#2563EB`
- `--color-primary-700`: `#1D4ED8`
- `--color-primary-800`: `#1E40AF`
- `--color-primary-900`: `#1E3A8A` (Darkest)

**Usage:**
- Primary buttons, links, active states
- Key metrics, important data points
- Brand elements, logos
- Interactive elements

### 2.2 Secondary Colors

**Secondary Purple** - Innovation, AI, premium
- `--color-secondary-50`: `#F5F3FF`
- `--color-secondary-100`: `#EDE9FE`
- `--color-secondary-200`: `#DDD6FE`
- `--color-secondary-300`: `#C4B5FD`
- `--color-secondary-400`: `#A78BFA`
- `--color-secondary-500`: `#8B5CF6` ⭐ **Main Secondary**
- `--color-secondary-600`: `#7C3AED`
- `--color-secondary-700`: `#6D28D9`
- `--color-secondary-800`: `#5B21B6`
- `--color-secondary-900`: `#4C1D95`

**Usage:**
- Accent elements, highlights
- Premium features, enterprise tier
- AI-related indicators
- Secondary actions

### 2.3 Semantic Colors

**Success Green** - Positive outcomes, improvements
- `--color-success-50`: `#F0FDF4`
- `--color-success-500`: `#22C55E` ⭐ **Main Success**
- `--color-success-700`: `#15803D`

**Warning Amber** - Alerts, attention needed
- `--color-warning-50`: `#FFFBEB`
- `--color-warning-500`: `#F59E0B` ⭐ **Main Warning**
- `--color-warning-700`: `#B45309`

**Error Red** - Errors, critical issues
- `--color-error-50`: `#FEF2F2`
- `--color-error-500`: `#EF4444` ⭐ **Main Error**
- `--color-error-700`: `#B91C1C`

**Info Blue** - Information, notifications
- `--color-info-50`: `#EFF6FF`
- `--color-info-500`: `#3B82F6` ⭐ **Main Info**
- `--color-info-700`: `#1D4ED8`

### 2.4 Neutral Colors

**Grays** - Text, backgrounds, borders
- `--color-gray-50`: `#F9FAFB` (Lightest background)
- `--color-gray-100`: `#F3F4F6` (Light background)
- `--color-gray-200`: `#E5E7EB` (Borders, dividers)
- `--color-gray-300`: `#D1D5DB`
- `--color-gray-400`: `#9CA3AF`
- `--color-gray-500`: `#6B7280` (Muted text)
- `--color-gray-600`: `#4B5563` (Secondary text)
- `--color-gray-700`: `#374151` (Primary text)
- `--color-gray-800`: `#1F2937` (Dark text)
- `--color-gray-900`: `#111827` (Darkest text)

**Usage:**
- `gray-50/100`: Backgrounds, cards
- `gray-200/300`: Borders, dividers
- `gray-500/600`: Secondary text, labels
- `gray-700/800`: Primary text, headings
- `gray-900`: Dark mode text

### 2.5 Color Usage Guidelines

**Do:**
- Use primary blue for main actions and brand elements
- Use semantic colors consistently (green = success, red = error)
- Maintain sufficient contrast for accessibility (WCAG AA minimum)
- Use neutral grays for text hierarchy

**Don't:**
- Mix color meanings (don't use red for success)
- Use too many colors in one interface
- Use low contrast combinations
- Deviate from the defined palette

---

## 3. Typography

### 3.1 Font Families

**Primary Font:** Inter (Sans-serif)
- Modern, clean, highly readable
- Excellent for UI and data display
- Web-safe, widely supported

**Monospace Font:** JetBrains Mono / Fira Code
- Code snippets, technical data
- API responses, configuration
- Data tables, metrics

**Fallback Stack:**
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 
             'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', sans-serif;
```

### 3.2 Type Scale

**Headings:**
- `--text-4xl`: `2.25rem` (36px) - Page titles, hero headings
- `--text-3xl`: `1.875rem` (30px) - Section headings
- `--text-2xl`: `1.5rem` (24px) - Subsection headings
- `--text-xl`: `1.25rem` (20px) - Card titles, large labels
- `--text-lg`: `1.125rem` (18px) - Emphasized text, small headings
- `--text-base`: `1rem` (16px) - Body text (default)
- `--text-sm`: `0.875rem` (14px) - Secondary text, captions
- `--text-xs`: `0.75rem` (12px) - Labels, fine print

**Line Heights:**
- Headings: `1.2` (tight)
- Body text: `1.5` (comfortable)
- Small text: `1.4` (readable)

### 3.3 Font Weights

- `--font-light`: `300` - Light text (rarely used)
- `--font-normal`: `400` - Regular body text
- `--font-medium`: `500` - Emphasized text, labels
- `--font-semibold`: `600` - Headings, important text
- `--font-bold`: `700` - Strong emphasis, page titles

### 3.4 Typography Usage

**Headings:**
- Use semantic HTML (`h1`, `h2`, `h3`, etc.)
- Maintain clear hierarchy (one `h1` per page)
- Use consistent spacing between headings and content

**Body Text:**
- Default: `16px` (1rem), `400` weight, `1.5` line height
- Maximum line length: `65-75 characters` for readability
- Use `medium` weight for emphasis, not bold

**Data & Metrics:**
- Use `semibold` or `bold` for numbers
- Larger size for key metrics (GEO Score, recall %)
- Monospace font for technical data

---

## 4. Spacing System

### 4.1 Spacing Scale

Based on 4px base unit for consistency:

- `--space-0`: `0` (0px)
- `--space-1`: `0.25rem` (4px)
- `--space-2`: `0.5rem` (8px)
- `--space-3`: `0.75rem` (12px)
- `--space-4`: `1rem` (16px) ⭐ **Base unit**
- `--space-5`: `1.25rem` (20px)
- `--space-6`: `1.5rem` (24px)
- `--space-8`: `2rem` (32px)
- `--space-10`: `2.5rem` (40px)
- `--space-12`: `3rem` (48px)
- `--space-16`: `4rem` (64px)
- `--space-20`: `5rem` (80px)
- `--space-24`: `6rem` (96px)

### 4.2 Spacing Usage

**Component Internal Spacing:**
- Small components: `space-2` to `space-4` (8-16px)
- Medium components: `space-4` to `space-6` (16-24px)
- Large components: `space-6` to `space-8` (24-32px)

**Section Spacing:**
- Between related sections: `space-8` (32px)
- Between major sections: `space-12` (48px)
- Page margins: `space-6` (24px) on mobile, `space-8` (32px) on desktop

**Card Padding:**
- Small cards: `space-4` (16px)
- Medium cards: `space-6` (24px)
- Large cards: `space-8` (32px)

**Form Spacing:**
- Between form fields: `space-4` (16px)
- Between form sections: `space-6` (24px)
- Form container padding: `space-6` (24px)

---

## 5. Layout System

### 5.1 Grid System

**Container Max Widths:**
- Small: `640px` (sm)
- Medium: `768px` (md)
- Large: `1024px` (lg)
- Extra Large: `1280px` (xl)
- 2XL: `1536px` (2xl)

**Grid Columns:**
- Mobile: `1 column`
- Tablet: `2 columns`
- Desktop: `3-4 columns`
- Wide: `4-6 columns`

**Gutters:**
- Mobile: `space-4` (16px)
- Desktop: `space-6` (24px)

### 5.2 Breakpoints

```css
/* Mobile First Approach */
--breakpoint-sm: 640px;   /* Small devices */
--breakpoint-md: 768px;   /* Tablets */
--breakpoint-lg: 1024px;  /* Desktops */
--breakpoint-xl: 1280px;  /* Large desktops */
--breakpoint-2xl: 1536px; /* Extra large */
```

### 5.3 Layout Patterns

**Dashboard Layout:**
- Sidebar: `256px` width (collapsible to `64px`)
- Main content: Flexible, max-width `1400px`
- Header: `64px` height (sticky)

**Card Layout:**
- Border radius: `8px` (standard), `12px` (large)
- Shadow: Subtle elevation (`0 1px 3px rgba(0,0,0,0.1)`)
- Padding: `space-6` (24px)

**Form Layout:**
- Max width: `640px` (single column)
- Label width: `120px` (desktop), full width (mobile)
- Input width: Flexible

---

## 6. Component Styles

### 6.1 Buttons

**Primary Button:**
- Background: `primary-500` (`#3B82F6`)
- Text: White
- Padding: `space-3` (12px) `space-4` (16px)
- Border radius: `6px`
- Font weight: `500` (medium)
- Hover: `primary-600` (darker)
- Active: `primary-700`

**Secondary Button:**
- Background: Transparent
- Border: `1px solid gray-300`
- Text: `gray-700`
- Hover: `gray-50` background

**Danger Button:**
- Background: `error-500` (`#EF4444`)
- Text: White
- Use for destructive actions

**Button Sizes:**
- Small: `space-2` (8px) `space-3` (12px), `text-sm`
- Medium: `space-3` (12px) `space-4` (16px), `text-base` (default)
- Large: `space-4` (16px) `space-6` (24px), `text-lg`

### 6.2 Inputs

**Text Input:**
- Border: `1px solid gray-300`
- Border radius: `6px`
- Padding: `space-3` (12px) `space-4` (16px)
- Focus: `primary-500` border, `primary-50` background
- Error: `error-500` border, `error-50` background

**Select/Dropdown:**
- Same styling as text input
- Dropdown menu: `gray-50` background, `8px` border radius

**Checkbox/Radio:**
- Size: `20px` × `20px`
- Border: `2px solid gray-400`
- Checked: `primary-500` background
- Focus: `primary-100` ring

### 6.3 Cards

**Standard Card:**
- Background: White
- Border: `1px solid gray-200`
- Border radius: `8px`
- Padding: `space-6` (24px)
- Shadow: `0 1px 3px rgba(0,0,0,0.1)`

**Elevated Card:**
- Same as standard, with stronger shadow: `0 4px 6px rgba(0,0,0,0.1)`

**Card Header:**
- Border bottom: `1px solid gray-200`
- Padding bottom: `space-4` (16px)
- Margin bottom: `space-4` (16px)

### 6.4 Tables

**Table Styles:**
- Border: `1px solid gray-200`
- Header: `gray-50` background, `semibold` text
- Row hover: `gray-50` background
- Cell padding: `space-3` (12px) `space-4` (16px)
- Alternating rows: Optional `gray-25` background

**Table Actions:**
- Icon buttons: `space-2` (8px) padding
- Hover: `gray-100` background

### 6.5 Badges/Tags

**Status Badges:**
- Success: `success-100` background, `success-700` text
- Warning: `warning-100` background, `warning-700` text
- Error: `error-100` background, `error-700` text
- Info: `info-100` background, `info-700` text

**Size:**
- Padding: `space-1` (4px) `space-2` (8px)
- Border radius: `4px`
- Font size: `text-xs` (12px)
- Font weight: `500` (medium)

### 6.6 Alerts/Notifications

**Alert Styles:**
- Success: `success-50` background, `success-700` text, `success-500` border
- Warning: `warning-50` background, `warning-700` text, `warning-500` border
- Error: `error-50` background, `error-700` text, `error-500` border
- Info: `info-50` background, `info-700` text, `info-500` border

**Padding:** `space-4` (16px)
**Border radius:** `6px`
**Border:** Left border `4px` solid

---

## 7. UI Patterns

### 7.1 Navigation

**Sidebar Navigation:**
- Background: White or `gray-50`
- Active item: `primary-500` background, white text
- Hover: `gray-100` background
- Icon size: `20px`
- Spacing: `space-2` (8px) between items

**Top Navigation:**
- Height: `64px`
- Background: White
- Border bottom: `1px solid gray-200`
- Sticky: Yes

### 7.2 Data Visualization

**Charts:**
- Primary color: `primary-500`
- Secondary color: `secondary-500`
- Grid lines: `gray-200`
- Text: `gray-600`

**Metrics Display:**
- Large numbers: `text-3xl` (30px), `bold`
- Labels: `text-sm` (14px), `gray-600`
- Trend indicators: Green (up), Red (down)

### 7.3 Loading States

**Skeleton Loaders:**
- Background: `gray-200`
- Border radius: `4px`
- Animation: Pulse effect

**Spinners:**
- Color: `primary-500`
- Size: `24px` (small), `32px` (medium), `48px` (large)

### 7.4 Empty States

**Empty State:**
- Icon: `gray-400`, `48px` size
- Heading: `text-lg` (18px), `gray-700`
- Description: `text-base` (16px), `gray-500`
- Action button: Primary button

---

## 8. Iconography

### 8.1 Icon Library

**Recommended:** Heroicons, Lucide, or Phosphor Icons
- Consistent stroke width: `1.5px` or `2px`
- Rounded corners for friendly feel
- Outline style for most icons
- Filled style for active states

### 8.2 Icon Sizes

- `--icon-xs`: `12px` - Small labels
- `--icon-sm`: `16px` - Inline with text
- `--icon-md`: `20px` - Default size
- `--icon-lg`: `24px` - Buttons, cards
- `--icon-xl`: `32px` - Empty states
- `--icon-2xl`: `48px` - Hero sections

### 8.3 Icon Usage

**Do:**
- Use consistent icon library
- Match icon style (all outline or all filled)
- Use appropriate sizes
- Add hover states for interactive icons

**Don't:**
- Mix icon libraries
- Use different stroke widths
- Make icons too small (< 12px)
- Use decorative icons unnecessarily

---

## 9. Imagery & Graphics

### 9.1 Image Style

**Photography:**
- Clean, professional
- Well-lit, high quality
- Minimal, uncluttered
- Business-focused

**Illustrations:**
- Modern, geometric
- Minimal color palette
- Data/tech theme
- Consistent style

### 9.2 Image Guidelines

**Do:**
- Use high-resolution images
- Optimize for web (WebP format)
- Maintain aspect ratios
- Add alt text for accessibility

**Don't:**
- Use low-quality images
- Stretch or distort images
- Use overly complex graphics
- Forget alt text

---

## 10. Animation & Transitions

### 10.1 Transition Timing

**Fast:** `150ms` - Hover states, small changes
**Medium:** `250ms` - Default transitions
**Slow:** `350ms` - Page transitions, large changes

**Easing:**
- Default: `ease-in-out`
- Enter: `ease-out`
- Exit: `ease-in`

### 10.2 Animation Guidelines

**Do:**
- Use subtle animations
- Keep transitions fast (< 350ms)
- Animate purposefully (draw attention)
- Respect `prefers-reduced-motion`

**Don't:**
- Over-animate
- Use slow animations (> 500ms)
- Animate everything
- Ignore accessibility preferences

### 10.3 Common Animations

**Hover:**
- Scale: `1.02` (subtle)
- Shadow: Increase elevation
- Color: Darken by one shade

**Loading:**
- Skeleton pulse
- Spinner rotation
- Progress bar fill

**Transitions:**
- Fade in/out: `opacity 0 → 1`
- Slide: `translateY(-10px) → 0`
- Scale: `scale(0.95) → 1`

---

## 11. Accessibility

### 11.1 Color Contrast

**WCAG AA Minimum:**
- Normal text: `4.5:1` contrast ratio
- Large text (18px+): `3:1` contrast ratio
- UI components: `3:1` contrast ratio

**WCAG AAA (Preferred):**
- Normal text: `7:1` contrast ratio
- Large text: `4.5:1` contrast ratio

### 11.2 Keyboard Navigation

**Tab Order:**
- Logical, sequential
- Skip links for main content
- Focus indicators visible

**Focus States:**
- Outline: `2px solid primary-500`
- Offset: `2px` from element
- Visible on all interactive elements

### 11.3 Screen Readers

**Semantic HTML:**
- Use proper heading hierarchy
- Label form inputs
- Use ARIA labels when needed
- Provide alt text for images

### 11.4 Responsive Design

**Mobile First:**
- Design for mobile, enhance for desktop
- Touch targets: Minimum `44px × 44px`
- Readable text without zooming
- No horizontal scrolling

---

## 12. Dark Mode (Future)

### 12.1 Dark Mode Colors

**Backgrounds:**
- Primary: `gray-900` (`#111827`)
- Secondary: `gray-800` (`#1F2937`)
- Cards: `gray-800` with subtle border

**Text:**
- Primary: `gray-100` (`#F3F4F6`)
- Secondary: `gray-400` (`#9CA3AF`)

**Borders:**
- `gray-700` (`#374151`)

### 12.2 Dark Mode Guidelines

- Maintain same contrast ratios
- Adjust all colors, not just backgrounds
- Test all components in dark mode
- Provide toggle for user preference

---

## 13. Implementation Guidelines

### 13.1 CSS Variables

Use CSS custom properties for all design tokens:

```css
:root {
  /* Colors */
  --color-primary-500: #3B82F6;
  --color-gray-700: #374151;
  
  /* Spacing */
  --space-4: 1rem;
  --space-6: 1.5rem;
  
  /* Typography */
  --text-base: 1rem;
  --font-medium: 500;
  
  /* Other */
  --border-radius: 6px;
  --transition: 250ms ease-in-out;
}
```

### 13.2 Component Library

**Recommended Approach:**
- Build reusable components
- Document component usage
- Maintain component library
- Version components

### 13.3 Design Tokens

**Structure:**
- Colors
- Typography
- Spacing
- Shadows
- Borders
- Transitions

**Usage:**
- Reference tokens, not hardcoded values
- Update tokens globally
- Maintain consistency

---

## 14. Brand Assets

### 14.1 Logo

**Primary Logo:**
The thevis logo consists of two main elements:
- **Eye Icon**: A stylized eye with gradient colors (light blue → purple → pink) with a glowing white pupil/iris in the center
- **Wordmark**: "thevis" in lowercase, modern sans-serif font
- **Tagline**: "Making brands visible to AI" (optional, used in marketing materials)

**Logo Specifications:**
- **File Location**: `/thevis.png` (or `/assets/images/thevis-logo.png`)
- **Format**: PNG with transparent background (for light backgrounds) or on dark blue background
- **Minimum size**: `120px` width for horizontal logo
- **Clear space**: `1x` logo height on all sides
- **Color variations**:
  - Full color (gradient eye + white text) on dark backgrounds
  - Full color on light backgrounds (with dark blue background option)
  - White/light version for dark backgrounds

**Logo Elements:**
- **Eye Icon Gradient**: 
  - Left: Light blue (`#60A5FA` or similar)
  - Center: Purple (`#8B5CF6` or similar)
  - Right: Pink (`#EC4899` or similar)
- **Eye Pupil**: Glowing white circle with subtle dark outline
- **Text Color**: White (`#FFFFFF`) for dark backgrounds
- **Tagline Color**: Light gray (`#9CA3AF` or `gray-400`)

**Logo Variations:**
- **Horizontal** (primary): Eye icon + "thevis" text side by side
- **Stacked**: Eye icon above "thevis" text (when vertical space is limited)
- **Icon Only**: Eye icon only (for favicon, app icons, small spaces)
- **Wordmark Only**: "thevis" text only (when icon doesn't fit)

**Usage Guidelines:**
- Always maintain aspect ratio
- Never stretch or distort the logo
- Use appropriate version for background (light/dark)
- Maintain clear space around logo
- Minimum size: `120px` width (horizontal), `80px` height (stacked)
- For favicon: Use icon-only version, `32px × 32px` or `64px × 64px`

### 14.2 Brand Colors

**Primary:** `#3B82F6` (Blue)
**Secondary:** `#8B5CF6` (Purple)
**Accent:** Use semantic colors as needed

**Logo Gradient Colors:**
- **Eye Gradient Start (Left)**: Light Blue `#60A5FA` (primary-400)
- **Eye Gradient Middle**: Purple `#8B5CF6` (secondary-500)
- **Eye Gradient End (Right)**: Pink `#EC4899` (pink-500)
- **Eye Pupil**: White `#FFFFFF` with subtle dark outline
- **Background (Logo)**: Dark Blue `#1E3A8A` (primary-900) or transparent

### 14.3 Typography

**Primary Font:** Inter
**Monospace:** JetBrains Mono / Fira Code

---

## 15. Quality Checklist

Before implementing any UI component, ensure:

- [ ] Uses design system colors
- [ ] Follows spacing scale
- [ ] Uses correct typography
- [ ] Meets accessibility standards (WCAG AA)
- [ ] Works on mobile devices
- [ ] Has proper focus states
- [ ] Includes loading/error states
- [ ] Matches brand personality
- [ ] Is consistent with existing components
- [ ] Has been tested with real content

---

## 16. Resources

### 16.1 Design Tools

- **Figma** - Design mockups
- **Storybook** - Component library
- **Tailwind CSS** - Utility-first CSS (recommended)
- **Phoenix LiveView** - Framework for UI

### 16.2 Reference

- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design](https://material.io/design)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**Last Updated:** 2024  
**Maintained By:** Design & Engineering Team  
**Version:** 1.0

