# ElevenLabs — Style Reference

> Clean white editorial with whispered headlines. A Bauhaus studio notebook — white paper, near-black ink, a single violet and orange spark for product moments.

**Theme:** light + dark (see [Dark Mode](#tokens--colors-dark-mode))

> **Source of truth:** `web/src/index.css` (`@theme` + `[data-theme="dark"]`). Mobile mirrors it in `mobile/lib/config/theme.dart`. If these disagree with this file, the code wins — update this file.

ElevenLabs runs on a near-neutral white minimalism: a pure white canvas (#ffffff) holding near-black type and a barely-tinted surface layer (#fdfdfb). The brand voice is quiet and confident — whisper-weight Waldenburg at 300 carves display headlines with extreme tightness (-0.02em), while Inter at 400/500 carries everything else with calm neutrality. Two accent sparks — vivid violet #1646ff and vivid orange #ff501c — only ignite inside product visuals (audio spheres, product icons), never as UI chrome. Components stay flat or barely elevated with hairline 1px borders, generous 20px radii on cards, and fully-pilled 9999px buttons. The system feels like a Bauhaus studio on cream paper: restrained, editorial, and technically precise.

## Tokens — Colors

| Name         | Value     | Token                  | Role                                                                                                                                              |
| ------------ | --------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Eggshell     | `#ffffff` | `--color-eggshell`     | Page canvas, button surfaces, card surfaces — pure white; token name kept for compatibility                                                    |
| Warm Taupe   | `#fdfdfb` | `--color-warm-taupe`   | Section bands, feature cards, and secondary surface level — a hair off white; cards rely on a stone border for separation                           |
| Stone        | `#e6e6e3` | `--color-stone`        | Hairline borders, dividers, icon plate backgrounds — light neutral gray                                                                           |
| Ink          | `#0b0b0b` | `--color-ink`          | Primary text, filled buttons, nav, links — near-black, the system's only hard contrast                                                            |
| Graphite     | `#30302e` | `--color-graphite`     | Strong secondary text, section labels — dark neutral gray for text that needs weight without true-black harshness                                 |
| Smoke        | `#60605c` | `--color-smoke`        | Body text, muted descriptions, caption labels — mid neutral gray; the dominant readable-but-quiet voice across cards and feature copy                |
| Ash          | `#8c8c87` | `--color-ash`          | Faintest helper text, tertiary descriptions — the softest gray, used when text should feel like a footnote                                        |
| Violet Spark | `#1646ff` | `--color-violet-spark` | Product visual accent — appears inside audio sphere illustrations and decorative product icons only; never used for UI chrome                     |
| Ember Orange | `#ff501c` | `--color-ember-orange` | Product visual accent — second sphere color and product icon highlight; paired with Violet Spark inside artwork, never in buttons or links        |

## Tokens — Colors (Dark Mode)

Applied via `[data-theme="dark"]` on web and `MewColorsDark` on mobile. Same token names, inverted values.

| Name         | Value     |
| ------------ | --------- |
| Eggshell     | `#141413` |
| Warm Taupe   | `#1c1c1a` |
| Stone        | `#2e2e2b` |
| Ink          | `#f0f0ee` |
| Graphite     | `#c8c8c4` |
| Smoke        | `#8c8c87` |
| Ash          | `#60605c` |
| Violet Spark | `#4a72ff` |
| Ember Orange | `#ff7a52` |

Shadows in dark mode: `--shadow-subtle: none`; `--shadow-subtle-inset: rgba(255, 255, 255, 0.04) 0px 0px 0px 0.5px inset`.

## Tokens — Typography

### Waldenburg — Display and heading type only. Used at 48/36/32px with weight 300 — the ultra-light weight is anti-convention; most sites use 600-700, this whisper-weight creates authority through restraint. Tight -0.02em tracking pulls letters closer at large sizes. Substitute: "Inter" weight 300, or "Söhne" light as a premium alternative. · `--font-waldenburg`

- **Substitute:** Inter (300) or Söhne Light
- **Weights:** 300
- **Sizes:** 32px, 36px, 48px
- **Line height:** 1.08–1.17
- **Letter spacing:** -0.96px at 48px, -0.72px at 36px, -0.64px at 32px (-0.0200em throughout)
- **OpenType features:** `"ss01" on if available`
- **Role:** Display and heading type only. Used at 48/36/32px with weight 300 — the ultra-light weight is anti-convention; most sites use 600-700, this whisper-weight creates authority through restraint. Tight -0.02em tracking pulls letters closer at large sizes. Substitute: "Inter" weight 300, or "Söhne" light as a premium alternative.

### Inter — Everything outside display: body, nav, buttons, links, captions, inputs, cards. Weight 400 is the default; weight 500 reserved for buttons and emphasized links. Sizes span 10–20px with relaxed line-heights (1.47–1.6) that give paragraphs breathing room. Slight +0.01em tracking (0.0100em) at 14–16px sizes adds legibility at small sizes. · `--font-inter`

- **Substitute:** Inter or system-ui
- **Weights:** 400, 500
- **Sizes:** 10px, 12px, 13px, 14px, 15px, 16px, 18px, 20px
- **Line height:** 1.20–2.06
- **Letter spacing:** 0.0100em at 14/15/16px sizes, normal elsewhere
- **Role:** Everything outside display: body, nav, buttons, links, captions, inputs, cards. Weight 400 is the default; weight 500 reserved for buttons and emphasized links. Sizes span 10–20px with relaxed line-heights (1.47–1.6) that give paragraphs breathing room. Slight +0.01em tracking (0.0100em) at 14–16px sizes adds legibility at small sizes.

### Geist Mono — Code-adjacent or technical micro-copy at 13px — used sparingly (freq=28) for technical labels or metadata. Single weight, generous 1.69 line-height. · `--font-geist-mono`

- **Substitute:** JetBrains Mono or IBM Plex Mono
- **Weights:** 400
- **Sizes:** 13px
- **Line height:** 1.69
- **Role:** Code-adjacent or technical micro-copy at 13px — used sparingly (freq=28) for technical labels or metadata. Single weight, generous 1.69 line-height.

### Type Scale

| Role       | Size | Line Height | Letter Spacing | Token               |
| ---------- | ---- | ----------- | -------------- | ------------------- |
| caption    | 10px | 1.6         | —              | `--text-caption`    |
| body-sm    | 14px | 1.5         | 0.14px         | `--text-body-sm`    |
| body       | 16px | 1.5         | 0.16px         | `--text-body`       |
| subheading | 18px | 1.6         | —              | `--text-subheading` |
| body-lg    | 20px | 1.35        | —              | `--text-body-lg`    |
| heading-sm | 32px | 1.13        | -0.64px        | `--text-heading-sm` |
| heading    | 36px | 1.17        | -0.72px        | `--text-heading`    |
| display    | 48px | 1.08        | -0.96px        | `--text-display`    |

## Tokens — Spacing & Shapes

**Base unit:** 4px

**Density:** comfortable

### Spacing Scale

| Name | Value | Token           |
| ---- | ----- | --------------- |
| 4    | 4px   | `--spacing-4`   |
| 8    | 8px   | `--spacing-8`   |
| 12   | 12px  | `--spacing-12`  |
| 16   | 16px  | `--spacing-16`  |
| 20   | 20px  | `--spacing-20`  |
| 24   | 24px  | `--spacing-24`  |
| 28   | 28px  | `--spacing-28`  |
| 32   | 32px  | `--spacing-32`  |
| 36   | 36px  | `--spacing-36`  |
| 40   | 40px  | `--spacing-40`  |
| 48   | 48px  | `--spacing-48`  |
| 56   | 56px  | `--spacing-56`  |
| 64   | 64px  | `--spacing-64`  |
| 72   | 72px  | `--spacing-72`  |
| 96   | 96px  | `--spacing-96`  |
| 160  | 160px | `--spacing-160` |

### Border Radius

| Element        | Value  |
| -------------- | ------ |
| tags           | 9999px |
| cards          | 20px   |
| inputs         | 4px    |
| buttons        | 9999px |
| large-cards    | 24px   |
| small-elements | 4-10px |

### Shadows

| Name     | Value                                                          | Token               |
| -------- | -------------------------------------------------------------- | ------------------- |
| subtle   | `rgba(0, 0, 0, 0.4) 0px 0px 1px 0px, rgba(0, 0, 0, 0.04) 0...` | `--shadow-subtle`   |
| subtle-2 | `rgba(0, 0, 0, 0.075) 0px 0px 0px 0.5px inset`                 | `--shadow-subtle-2` |
| subtle-3 | `rgba(0, 0, 0, 0.1) 0px 0px 0px 0.5px inset`                   | `--shadow-subtle-3` |
| subtle-4 | `rgba(0, 0, 0, 0.1) 0px 0px 0px 1px inset`                     | `--shadow-subtle-4` |
| subtle-5 | `rgba(0, 0, 0, 0.4) 0px 0px 1px 0px, rgba(0, 0, 0, 0.04) 0...` | `--shadow-subtle-5` |
| subtle-6 | `rgba(255, 255, 255, 0.6) 0px 0px 0px 1px inset`               | `--shadow-subtle-6` |
| subtle-7 | `rgb(230, 230, 227) 0px 0px 0px 0.5px inset`                   | `--shadow-subtle-7` |

### Layout

- **Page max-width:** 1280px
- **Section gap:** 96-125px
- **Card padding:** 32px
- **Element gap:** 8-16px

## Components

### Filled Pill Button

**Role:** Primary action

Black (#0b0b0b) fill, white text, 9999px radius, 16px horizontal padding, Inter 14px/500. 1px solid #e5e5e5 border (legacy support). Used for 'Sign up', 'Create an AI agent', 'Learn more'. The pill shape is the system's most recognizable component.

### Outline Pill Button

**Role:** Secondary action

White (#ffffff) fill, black text, 9999px radius, 14px horizontal padding, Inter 14px/500. 1px solid #e5e5e5 border. Used for 'Contact sales', 'Log in'. Lower visual weight than the filled variant — pairs beside it without competing.

### Ghost Link Button

**Role:** Tertiary navigation or in-text action

Transparent fill, black text, 9999px radius, Inter 14px/500. 1px solid #e5e5e5 border. Used for nav items and inline actions. No visible fill until hover.

### Feature Card (Taupe)

**Role:** Feature showcase panel

#fdfdfb warm taupe fill, 1px #e6e6e3 stone border, 20px radius, 24px padding, no shadow (`.card-taupe`). The dominant card pattern (22 occurrences). Flat, quiet, sits on the canvas without elevation.

### White Card with Whisper Shadow

**Role:** Elevated content card

White (#ffffff) fill, 20px radius, 16px all-side padding, three-layer whisper shadow (1px hard edge + 1px blur + 4px blur at 4% opacity). Used sparingly — only when a card needs to sit above other content with subtle separation.

### Large Feature Card

**Role:** Hero feature block

#fdfdfb fill, 24px radius (slightly larger than standard 20px), generous internal padding. Used for flagship feature showcases that need more visual breathing room.

### Tab Pill

**Role:** Product switcher in feature panels

White fill, black text, 9999px radius, 1px border. Active state marked by a small colored dot (orange for ElevenCreative, teal for ElevenAgents, gray for ElevenAPI). Tabs sit inline above the card content.

### Hairline Divider

**Role:** Section separation

1px solid #e6e6e3 stone-colored line. Preferred over whitespace when sections need explicit separation. Used 54 times across the page — the most common border pattern.

### Audio Sphere Visual

**Role:** Product showcase graphic

Large circular gradient sphere (roughly 200px diameter) with soft radial gradients blending violet #1646ff, orange #ff501c, pink, and warm tones. Centered play-button overlay. No hard edges — these are the system's signature visual and appear 3x in a carousel row.

### Logo Wordmark

**Role:** Brand identity

Black text reading 'ElevenLabs' in Inter bold/semibold. Consistent across header and footer. No icon mark — the wordmark alone carries the brand.

### Top Nav Bar

**Role:** Primary navigation

Transparent on eggshell canvas, 50px height. Logo left, nav links center-left (Inter 14px), auth buttons right (outline 'Log in' + filled 'Sign up'). No background fill — the nav is invisible until scroll.

### Trust Logo Grid

**Role:** Social proof section

6-column grid of partner logos (Twilio, Disney, KPN, NVIDIA, Meta, etc.) rendered in grayscale at low contrast. Logos sit on the eggshell canvas with generous padding — not boxed in cards. 'Read all stories' outline button top-right.

## Do's and Don'ts

### Do

- Use Waldenburg at weight 300 for all display headlines 32px+; never apply bold or semibold weights to it — the whisper-weight is the brand's signature restraint.
- Set all buttons, tags, and tab pills to 9999px radius; the pill shape is non-negotiable and defines the system's most recognizable component.
- Use #0b0b0b filled buttons paired with #ffffff outline buttons as the only button hierarchy — do not introduce colored CTA fills.
- Reserve #1646ff violet and #ff501c orange exclusively for product visuals (audio spheres, product icons, illustration accents); never apply them to UI text, borders, or interactive elements.
- Use 1px solid #e6e6e3 hairline borders for section separation; prefer borders over drop shadows for the flat editorial feel.
- Apply -0.02em letter-spacing on all Waldenburg headlines at 32px+ and +0.01em tracking on Inter body at 14–16px — the opposite tracking directions create a deliberate contrast between display and body.
- Stack surfaces as eggshell → taupe → stone, always via the tokens — never hardcode hex values in components.

### Don't

- Do not bold or semibold Waldenburg — the weight-300 whisper is the brand's most distinctive choice and bolding destroys it.
- Do not use violet #1646ff or orange #ff501c for buttons, links, badges, or any interactive UI element; these colors are decoration-only.
- Do not add heavy drop shadows; the system uses near-invisible 1px shadows only — no blurred elevation effects.
- Do not introduce new accent colors beyond the two product-visual sparks; the palette is intentionally 97% achromatic.
- Do not use sharp corners (<8px) on cards or feature panels; the 20–24px radii are a signature.
- Do not hardcode #ffffff or #000000; use `--color-eggshell` / `--color-ink` so dark mode inverts correctly.
- Do not use display-weight fonts (anything heavier than Waldenburg 300) for body copy; Inter 400/500 owns everything below 24px.

## Surfaces

| Level | Name            | Value     | Purpose                                                                                           |
| ----- | --------------- | --------- | ------------------------------------------------------------------------------------------------- |
| 1     | Eggshell Canvas | `#ffffff` | Base page background — pure white                                                                 |
| 2     | Warm Taupe      | `#fdfdfb` | Section bands and card surfaces that need to sit one step above the canvas without a border       |
| 3     | Stone Plate     | `#e6e6e3` | Icon plates, subtle elevated backgrounds — slightly deeper than taupe for small isolated elements |

## Elevation

- **Buttons and elevated cards:** `rgba(0, 0, 0, 0.4) 0px 0px 1px 0px, rgba(0, 0, 0, 0.04) 0px 1px 1px 0px, rgba(0, 0, 0, 0.04) 0px 2px 4px 0px`
- **Inset borders / focus halos:** `rgba(0, 0, 0, 0.075) 0px 0px 0px 0.5px inset`

## Imagery

Product visuals dominate the imagery language: large soft-edged audio sphere gradients (200px+ circles with radial violet-to-orange-to-pink blends) serve as the hero graphic. Logos in the trust section appear in low-contrast grayscale against the eggshell canvas. Photography is minimal — no lifestyle or product photography detected. Iconography is sparse and monochrome (black outlined or filled icons, no chromatic icons). The visual system feels more like a design publication than a product catalog — editorial restraint over marketing spectacle.

## Layout

Full-width sections flow vertically in a single max-width 1280px centered column with 64px outer gutters. Hero is asymmetric: left-aligned headline at 48px Waldenburg, right-aligned body description, with two pill buttons stacked below the headline. Below the hero, a large feature panel with tab navigation spans the full content width. Sections alternate between eggshell canvas and taupe band backgrounds with 96–125px vertical gaps. Footer is a compact single band. Navigation is a minimal top bar — no sticky behavior, no mega-menu. Content rhythm is editorial: generous whitespace, one major visual per section, no card grids below the trust section.

## Agent Prompt Guide

**Quick Color Reference**

- text: #0b0b0b (primary), #60605c (body), #8c8c87 (caption)
- background: #ffffff (canvas), #fdfdfb (card surface)
- border: #e6e6e3 (hairline), #e5e5e5 (button border)
- accent: #1646ff (violet spark — product visuals only)
- accent: #ff501c (ember orange — product visuals only)
- primary action: #0b0b0b (filled action)

**3-5 Example Component Prompts**

1. Create a hero headline: 'Bringing technology to life' at 48px Waldenburg weight 300, color #0b0b0b, letter-spacing -0.96px, line-height 1.08. Left-aligned on #ffffff canvas.

2. Create a primary button: 'Sign up' — 9999px radius, #0b0b0b fill, white text, Inter 14px/500, 16px horizontal padding, 1px solid #e5e5e5 border.

3. Create a secondary button: 'Contact sales' — 9999px radius, #ffffff fill, #0b0b0b text, Inter 14px/500, 14px horizontal padding, 1px solid #e5e5e5 border.

4. Create a feature card: #fdfdfb fill, 20px radius, 32px horizontal padding, no shadow. Title at 36px Waldenburg 300, description at 16px Inter 400 in #60605c.

5. Create an audio sphere visual: 200px circle with radial-gradient blending #1646ff, #ff501c, and pink, no hard edge. Center play icon in white circle 48px diameter.

## Similar Brands

- **Linear** — Same whisper-weight display headlines paired with monochrome UI and pill-shaped buttons; both achieve authority through typographic restraint rather than color.
- **Vercel** — Same near-white warm canvas with stark black text and pill buttons; both use minimal color and let typography carry the brand.
- **Stripe** — Same editorial restraint with hairline borders, generous whitespace, and accent colors reserved for illustrations rather than UI chrome.
- **Notion** — Same warm off-white palette with taupe secondary surfaces and pill-shaped interactive elements; both feel like paper rather than glass.
- **Framer** — Same Bauhaus-influenced minimalism with whisper-weight headlines and a 97% achromatic palette that lets single accent colors feel significant.

## Quick Start

### CSS Custom Properties

```css
:root {
  /* Colors */
  --color-eggshell: #ffffff;
  --color-warm-taupe: #fdfdfb;
  --color-stone: #e6e6e3;
  --color-ink: #0b0b0b;
  --color-graphite: #30302e;
  --color-smoke: #60605c;
  --color-ash: #8c8c87;
  --color-violet-spark: #1646ff;
  --color-ember-orange: #ff501c;

  /* Typography — Font Families */
  --font-waldenburg:
    "Waldenburg", ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    "Segoe UI", Roboto, sans-serif;
  --font-inter:
    "Inter", ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    "Segoe UI", Roboto, sans-serif;
  --font-geist-mono:
    "Geist Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
    monospace;

  /* Typography — Scale */
  --text-caption: 10px;
  --leading-caption: 1.6;
  --text-body-sm: 14px;
  --leading-body-sm: 1.5;
  --tracking-body-sm: 0.14px;
  --text-body: 16px;
  --leading-body: 1.5;
  --tracking-body: 0.16px;
  --text-subheading: 18px;
  --leading-subheading: 1.6;
  --text-body-lg: 20px;
  --leading-body-lg: 1.35;
  --text-heading-sm: 32px;
  --leading-heading-sm: 1.13;
  --tracking-heading-sm: -0.64px;
  --text-heading: 36px;
  --leading-heading: 1.17;
  --tracking-heading: -0.72px;
  --text-display: 48px;
  --leading-display: 1.08;
  --tracking-display: -0.96px;

  /* Typography — Weights */
  --font-weight-light: 300;
  --font-weight-regular: 400;
  --font-weight-medium: 500;

  /* Spacing */
  --spacing-unit: 4px;
  --spacing-4: 4px;
  --spacing-8: 8px;
  --spacing-12: 12px;
  --spacing-16: 16px;
  --spacing-20: 20px;
  --spacing-24: 24px;
  --spacing-28: 28px;
  --spacing-32: 32px;
  --spacing-36: 36px;
  --spacing-40: 40px;
  --spacing-48: 48px;
  --spacing-56: 56px;
  --spacing-64: 64px;
  --spacing-72: 72px;
  --spacing-96: 96px;
  --spacing-160: 160px;

  /* Layout */
  --page-max-width: 1280px;
  --section-gap: 96-125px;
  --card-padding: 32px;
  --element-gap: 8-16px;

  /* Border Radius */
  --radius-md: 4px;
  --radius-lg: 10px;
  --radius-2xl: 16px;
  --radius-2xl-2: 20px;
  --radius-3xl: 24px;
  --radius-3xl-2: 28px;
  --radius-full: 9999px;

  /* Named Radii */
  --radius-tags: 9999px;
  --radius-cards: 20px;
  --radius-inputs: 4px;
  --radius-buttons: 9999px;
  --radius-large-cards: 24px;
  --radius-small-elements: 4-10px;

  /* Shadows */
  --shadow-subtle:
    rgba(0, 0, 0, 0.4) 0px 0px 1px 0px, rgba(0, 0, 0, 0.04) 0px 1px 1px 0px,
    rgba(0, 0, 0, 0.04) 0px 2px 4px 0px;
  --shadow-subtle-2: rgba(0, 0, 0, 0.075) 0px 0px 0px 0.5px inset;
  --shadow-subtle-3: rgba(0, 0, 0, 0.1) 0px 0px 0px 0.5px inset;
  --shadow-subtle-4: rgba(0, 0, 0, 0.1) 0px 0px 0px 1px inset;
  --shadow-subtle-5:
    rgba(0, 0, 0, 0.4) 0px 0px 1px 0px, rgba(0, 0, 0, 0.04) 0px 2px 4px 0px;
  --shadow-subtle-6: rgba(255, 255, 255, 0.6) 0px 0px 0px 1px inset;
  --shadow-subtle-7: rgb(230, 230, 227) 0px 0px 0px 0.5px inset;

  /* Surfaces */
  --surface-eggshell-canvas: #ffffff;
  --surface-warm-taupe: #fdfdfb;
  --surface-stone-plate: #e6e6e3;
}
```

### Tailwind v4

```css
@theme {
  /* Colors */
  --color-eggshell: #ffffff;
  --color-warm-taupe: #fdfdfb;
  --color-stone: #e6e6e3;
  --color-ink: #0b0b0b;
  --color-graphite: #30302e;
  --color-smoke: #60605c;
  --color-ash: #8c8c87;
  --color-violet-spark: #1646ff;
  --color-ember-orange: #ff501c;

  /* Typography */
  --font-waldenburg:
    "Waldenburg", ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    "Segoe UI", Roboto, sans-serif;
  --font-inter:
    "Inter", ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    "Segoe UI", Roboto, sans-serif;
  --font-geist-mono:
    "Geist Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
    monospace;

  /* Typography — Scale */
  --text-caption: 10px;
  --leading-caption: 1.6;
  --text-body-sm: 14px;
  --leading-body-sm: 1.5;
  --tracking-body-sm: 0.14px;
  --text-body: 16px;
  --leading-body: 1.5;
  --tracking-body: 0.16px;
  --text-subheading: 18px;
  --leading-subheading: 1.6;
  --text-body-lg: 20px;
  --leading-body-lg: 1.35;
  --text-heading-sm: 32px;
  --leading-heading-sm: 1.13;
  --tracking-heading-sm: -0.64px;
  --text-heading: 36px;
  --leading-heading: 1.17;
  --tracking-heading: -0.72px;
  --text-display: 48px;
  --leading-display: 1.08;
  --tracking-display: -0.96px;

  /* Spacing */
  --spacing-4: 4px;
  --spacing-8: 8px;
  --spacing-12: 12px;
  --spacing-16: 16px;
  --spacing-20: 20px;
  --spacing-24: 24px;
  --spacing-28: 28px;
  --spacing-32: 32px;
  --spacing-36: 36px;
  --spacing-40: 40px;
  --spacing-48: 48px;
  --spacing-56: 56px;
  --spacing-64: 64px;
  --spacing-72: 72px;
  --spacing-96: 96px;
  --spacing-160: 160px;

  /* Border Radius */
  --radius-md: 4px;
  --radius-lg: 10px;
  --radius-2xl: 16px;
  --radius-2xl-2: 20px;
  --radius-3xl: 24px;
  --radius-3xl-2: 28px;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-subtle:
    rgba(0, 0, 0, 0.4) 0px 0px 1px 0px, rgba(0, 0, 0, 0.04) 0px 1px 1px 0px,
    rgba(0, 0, 0, 0.04) 0px 2px 4px 0px;
  --shadow-subtle-2: rgba(0, 0, 0, 0.075) 0px 0px 0px 0.5px inset;
  --shadow-subtle-3: rgba(0, 0, 0, 0.1) 0px 0px 0px 0.5px inset;
  --shadow-subtle-4: rgba(0, 0, 0, 0.1) 0px 0px 0px 1px inset;
  --shadow-subtle-5:
    rgba(0, 0, 0, 0.4) 0px 0px 1px 0px, rgba(0, 0, 0, 0.04) 0px 2px 4px 0px;
  --shadow-subtle-6: rgba(255, 255, 255, 0.6) 0px 0px 0px 1px inset;
  --shadow-subtle-7: rgb(230, 230, 227) 0px 0px 0px 0.5px inset;
}
```
