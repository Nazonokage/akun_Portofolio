# PSG (Paris Saint-Germain) – 1st Year Project

A multi-page web project made with **HTML + CSS + JavaScript** that presents information about **Paris Saint-Germain (PSG)** (1st team, women’s team, handball, esports), plus features like fixtures, merch market, auctions, and a login/register page.

## Project Structure

- **HTML pages (site sections)**
  - `Home.html` – main landing page and navigation
  - `1stSquad.html` – 1st team players (forwards/midfield/defenders/goalkeepers)
  - `WSquad.html` – women’s team players
  - `Hanball.html` – handball players
  - `Esports.html` – esports teams/tables
  - `Fixtures 1st team.html` – fixtures + league table (men)
  - `Fixtures W Team.html` – fixtures + league table (women)
  - `Mrkt.html` – PSG merch / tickets section
  - `Auction.html` – items available for bidding
  - `login.html` – login + register UI

- **Shared assets**
  - `1stSquad.css` – global styles used across pages
  - `1stSquad.js` – shared JavaScript (dropdown toggle, scroll-to-top, etc.)
  - `pic/` – large collection of images used by the site
  - `prf/` – player/manager images

## Main Features

- **Navigation + UI components**
  - Dropdown menu for language selection and sections
  - Search bar UI (front-end)
  - Back-to-top button (uses `scrollToTop()` from JS)

- **Team Information Pages**
  - Player lists are shown using tables grouped by roles (e.g., forwards, midfielders, defenders, goalkeepers)
  - Each player row includes name links + local images

- **Fixtures & Standings**
  - Fixtures and a league standings table are included for both the men’s and women’s pages
  - Includes match highlights links (YouTube URLs)

- **Market & Auction Sections**
  - `Mrkt.html`: merch/tickets list with prices and “Login and Buy” links
  - `Auction.html`: bidding tables for signed items and worn shirts/boots

- **Authentication UI (Frontend)**
  - `login.html` provides a login/register form UI (no backend included)

## Technologies Used

- **HTML** (multi-page static website)
- **CSS** (shared stylesheet + page-level inline styles)
- **JavaScript** (shared functions such as dropdown toggle + scroll-to-top)
- **Font Awesome** (loaded via CDN for icons)

## How to Run

Because this project is static:

1. Open `Home.html` in a browser.
2. Navigate using the links in the dropdown/menu.

> Tip: Make sure you keep the folder structure the same, especially `pic/` and `prf/`, because the pages reference images with relative paths.

## Notes

- Links to external pages (Wikipedia/YouTube/Fandom) are included in player and match sections.
- This project focuses on layout, content organization, and basic front-end interactions for a 1st-year assignment.

