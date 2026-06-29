**Here's a clean `TODO.md`** you can copy directly into your new Next.js project:

```markdown
# TODO.md - Portfolio Migration (Flutter → Next.js)

## Goal
Migrate to Next.js for better mobile performance while keeping (or enhancing) the neon holographic tactical board wow-factor. Learn modern Next.js patterns along the way.

### Phase 1: Project Setup (Today)
- [ ] Create new Next.js 15 app (`npx create-next-app@latest ... --typescript --tailwind --eslint --app`)
- [ ] Install dependencies:
  ```bash
  npm install framer-motion lucide-react
  npm install konva react-konva
  npm install @types/konva
  # Optional: for particles/neon effects
  # npm install canvas-confetti
  ```
- [ ] Setup Tailwind + custom neon utilities (glows, glassmorphism, aurora bg)
- [ ] Copy useful data/logic from old `lib/` folder:
  - Profile data
  - Projects info
  - Any formation detection / k-means logic
- [ ] Configure dark mode + neon theme

### Phase 2: Core Structure
- [ ] Create main layout with smooth scroll + navigation
- [ ] Build sections:
  - [ ] Hero Section (with board teaser)
  - [ ] Tactical Board (main interactive feature)
  - [ ] About
  - [ ] Experience / Skills
  - [ ] Projects
  - [ ] Contact
- [ ] Add glassmorphism + neon effects (CSS + Framer Motion)

### Phase 3: Tactical Board (The Star)
- [ ] Implement core board using Konva.js:
  - [ ] Draggable players with physics-like movement
  - [ ] Tilt / perspective on drag
  - [ ] Tap to show player stats
  - [ ] Edit mode (double tap to reposition)
  - [ ] Formation detection (reuse old logic if possible)
  - [ ] Heatmap overlay
- [ ] Add scroll-triggered parallax + background effects
- [ ] Mobile optimizations (simplify on small screens)

### Phase 4: Polish & Performance
- [ ] Optimize images (WebP + Next/Image)
- [ ] Add Framer Motion animations
- [ ] Implement loading states + custom loader
- [ ] SEO: Metadata, Open Graph, structured data
- [ ] Lighthouse score > 95 (especially Performance on mobile)
- [ ] Deploy to Vercel

### Phase 5: Nice-to-Haves
- [ ] Dark/light mode toggle with neon variants
- [ ] PWA support
- [ ] Interactive resume (PDF + on-page version)
- [ ] Subtle particle / scanline effects
- [ ] Analytics

## Migration Notes
- Keep old Flutter repo as backup/reference
- Save old `lib/` folder content (especially data models and algorithms)
- Focus on mobile performance from day 1

**Current Priority:** Finish Phase 1 + start Tactical Board component.

---

Made with ❤️ | Joshua Porras Portfolio
```

---

**Quick Tip for Cursor:**
Copy the data from your old `lib/data/profile_data.dart` and `info/` folder first — it will help you keep content consistent.

Want me to also generate:
- The `TacticalBoard.tsx` starter code?
- A `globals.css` with neon utilities?
- Or the main `page.tsx` layout?

Just tell me what to create next! You're going to crush this. 🔥