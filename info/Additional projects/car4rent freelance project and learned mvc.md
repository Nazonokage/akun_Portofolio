# Car4Rent — Car Rental Management System (PHP + MySQL)

**Car4Rent** is a simple car rental web application built with **PHP (no framework)** and **MySQL**. It provides:

- Public pages to browse cars and view car details
- Client registration + login
- Car rental requests (queued with date range + pricing)
- Rented cars page for clients (view/cancel/extend)
- Admin dashboard to manage cars, users, and rental queue (confirm/approve/decline/delete)

> Note: This repo expects you to set up the database locally and configure MySQL credentials.

---

## Features

### Client (User)
- Register account
- Login
- View available cars
- View car details
- Start a rental request with:
  - Start date
  - End date
  - Auto-calculated total days and total price
- View rented cars (requests) and manage them (cancel/extend depending on UI/actions)

### Admin
- Login using `view/Admin/account.json`
- View rental queue with user + car details
- Confirm/approve/decline rentals
- Manage cars (add/edit/delete)
- Manage users (delete users if no active rentals)

---

## Tech Stack

- **PHP**
- **MySQL**
- **HTML/CSS/JavaScript** (static pages + custom CSS)
- **mysqli** for database access

---

## Project Structure (high level)

- `index.php` - entry point and router
- `controller/controller.php` - routing + request handling
- `model/model.php` - database layer + business logic
- `html/` - page fragments (header/footer/home/about)
- `view/` - UI pages (login/register/admin pages/car pages)
- `css/` - styling files
- `images/` - sample images
- `uploads/` - uploaded/attached car images
- `Newsalakyan.sql` - database schema

---

## Database Setup

1. Create/import the database using `Newsalakyan.sql`.
2. The SQL creates a database named: **`salakyan`** and the required tables.
3. Ensure the tables exist:
   - `cars`
   - `users`
   - `rental_queue`

### MySQL Connection
Your DB credentials are currently set in:
- `model/model.php`

Find this line:
```php
$this->db = new mysqli("localhost", "root", "", "salakyan");
```
Replace `root` / password if needed.

---

## Run Locally

### Using PHP built-in server (quick test)
From the project directory:

```bash
php -S localhost:8000
```

Then open:
- `http://localhost:8000/index.php`

> If you use XAMPP/WAMP, place the project under your web root (e.g. `htdocs/Car4Rent`) and access it via your local server.

---

## Admin Credentials

Admin login is read from:
- `view/Admin/account.json`

This file must contain keys like:
- `email`
- `password`

---

## Important Notes / Caveats

- Passwords in `users` appear to be stored and compared as plain values in current code. For production use, you should hash passwords with `password_hash()` / `password_verify()`.
- Ensure `uploads/` is writable so image uploads work.
- This project uses query-string routing via `?command=...`.

---

## Screens / Routes (by command)

The controller routes requests like:
- `?command=home`
- `?command=about`
- `?command=viewCars`
- `?command=searchCars&keyword=...`
- `?command=viewCarDetails&ID=...`
- `?command=login`
- `?command=register`
- `?command=adminPage`
- `?command=RentedCars`

---

## License

MIT (or replace with your preferred license).
