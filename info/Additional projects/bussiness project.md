# AE Group of Companies — Business Website

A professional multi-page website built with **React + Vite + Tailwind CSS**, designed to advertise and provide information for two businesses under the AE Group: **Philippine Scapes Realty** and **AE Food Trading**.

---

## 📌 Purpose

This website serves as a digital presence for the client's businesses, allowing visitors to:
- Learn about both companies
- Browse AE Food Trading's products
- Get in touch via email or Facebook
- Navigate seamlessly between business pages

---

## 🗺️ Website Flow

```
Landing Page (/)
├── Hero section — both business names side by side
├── "About Us" button
├── Two clickable business cards (Realty / Food Trading)
└── Navbar with links to both business pages

Philippine Scapes Realty (/realty)
├── Business description
├── Facebook page link
└── Contact info (email + Facebook)

AE Food Trading (/food-trading)
├── Business description
├── Placeholder product cards (real products to be added later)
└── Facebook page link (to be added later)

About Us (/about)
└── Combined story and mission of both businesses

Contact Us (/contact)
└── Email + Facebook contact info
    (inquiry form can be added in a future update)
```

---

## 📁 Project Structure

```
src/
├── pages/
│   ├── LandingPage.jsx         ← Main landing/home page
│   ├── RealtyPage.jsx          ← Philippine Scapes Realty page
│   ├── FoodTradingPage.jsx     ← AE Food Trading page + products
│   ├── AboutPage.jsx           ← About both businesses
│   └── ContactPage.jsx         ← Contact info page
├── components/
│   ├── Navbar.jsx              ← Sticky top navigation
│   ├── ParticlesBackground.jsx ← Animated background
│   ├── BusinessCard.jsx        ← Reusable card for landing page
│   └── ProductCard.jsx         ← Reusable card for food products
├── App.jsx                     ← Routes and layout
├── App.css                     ← Global styles (earthy/burgundy theme)
└── index.css                   ← Tailwind base + CSS variables
```

---

## 🎨 Design

- **Color theme:** Earthy burgundy tones (`#75000C`, `#6B4423`, `#F0E5C1`)
- **Background:** Animated particle canvas with hexagonal shapes
- **Font:** Inter (system sans-serif fallback)
- **Style:** Warm, professional, clean

---

## 🛠️ Tech Stack

| Tool | Version | Purpose |
|---|---|---|
| React | 19.x | UI framework |
| Vite | 8.x | Build tool & dev server |
| React Router DOM | 7.x | Client-side routing |
| Tailwind CSS | 3.x | Utility-first styling |
| Particles.js | 2.x | Background animation |

---

## 🚀 Getting Started

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

---

## 📄 Pages — Build Status

| Page | Route | Status |
|---|---|---|
| Landing Page | `/` | 🔄 In Progress |
| Philippine Scapes Realty | `/realty` | ⏳ Planned |
| AE Food Trading | `/food-trading` | ⏳ Planned |
| About Us | `/about` | 🔄 Needs Cleanup |
| Contact Us | `/contact` | ⏳ Planned |

---

## 📬 Business Contact Info

| Business | Facebook | Email |
|---|---|---|
| Philippine Scapes Realty | [Facebook Page](https://www.facebook.com/profile.php?id=61584272253847) | *(to be added)* |
| AE Food Trading | *(to be added later)* | *(to be added)* |

---

## 🔮 Future Updates

- [ ] Add real logos for both businesses
- [ ] Add real product names and photos for AE Food Trading
- [ ] Add Facebook page for AE Food Trading
- [ ] Add contact/inquiry form on Contact page
- [ ] Add Gallery or Photos page (optional)
- [ ] Add actual email address to Contact page

---

## 📝 Notes for Developer

- The current codebase still contains leftover template files (`GetStartedPage.jsx`, placeholder text like "Title to Change") — these will be replaced during the build phase.
- Product cards in `/food-trading` are placeholders until the client provides real product info.
- All Facebook links and contact details should be updated by the client before going live.
