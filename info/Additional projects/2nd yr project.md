# Movie Ticketing System

A Java-based desktop application for managing movie ticket sales and reservations with priority-based pricing.

## About
This project implements a movie ticketing system with user authentication, ticket management, and priority-based pricing discounts. Built with Java and MySQL for reliable data persistence.

## Features

### Core Functionality
- User authentication (Admin/User roles)
- Ticket booking and management 
- Priority discount system
- Real-time transaction tracking
- Ticket printing

### Priority Discounts
- VIP: 70% off
- Student: 15% off  
- Senior: 15% off
- PWD: 15% off
- Child: 15% off
- Regular: No discount

## Requirements

- Java 8+ 
- MySQL Server
- MySQL Connector/J 8.1.0
- IDE (VS Code recommended)

## Getting Started

1. Clone the repository
```bash
git clone https://github.com/Nazonokage/Movie-Ticketing-Project.git
```

2. Create MySQL database and table:
```sql
CREATE DATABASE tiketa;

CREATE TABLE registrazione (
    tkt_id INT AUTO_INCREMENT PRIMARY KEY,
    C_nme VARCHAR(255) NOT NULL,
    movie VARCHAR(255) NOT NULL, 
    prc DOUBLE NOT NULL,
    seat VARCHAR(255) NOT NULL,
    prty VARCHAR(255) NOT NULL,
    RegDateTime DATETIME NOT NULL
);
```

3. Import project into IDE
4. Add MySQL connector from `lib/` folder
5. Run `App.java`

## Default Login
- Admin: username: `admin`, password: `admin`
- User: username: `user`, password: `user`

## Project Structure
```
└── src/
    ├── App.java             # Main app & login
    ├── Ticketing_main.java  # Core ticketing UI
    ├── DataDisplay.java     # Transaction view
    ├── modifica.java        # Edit functionality  
    └── printa.java          # Print tickets
```

## Contributing
1. Fork the project
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open pull request

## License
Distributed under the MIT License. See `LICENSE` for details.