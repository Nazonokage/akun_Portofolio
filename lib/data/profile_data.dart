import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class SkillRating {
  final String name;
  final int score;
  final int maxScore;

  const SkillRating({
    required this.name,
    required this.score,
    this.maxScore = 10,
  });

  double get normalized => score / maxScore;
}

class ExperienceEntry {
  final String title;
  final String company;
  final String location;
  final String period;
  final List<String> bullets;
  final MatchEventType eventType;

  const ExperienceEntry({
    required this.title,
    required this.company,
    required this.location,
    required this.period,
    required this.bullets,
    this.eventType = MatchEventType.deployment,
  });
}

enum MatchEventType {
  deployment,
  support,
  hardware,
  freelance,
}

enum ProjectCategory {
  flutter,
  web,
  backend,
  desktop,
  tooling,
  security,
}

class ProjectEntry {
  final String name;
  final String subtitle;
  final String stack;
  final String year;
  final List<String> bullets;
  final Color accent;
  final bool featured;
  final ProjectCategory category;
  final String? githubUrl;
  final String? liveUrl;

  const ProjectEntry({
    required this.name,
    required this.subtitle,
    required this.stack,
    required this.year,
    required this.bullets,
    required this.accent,
    this.featured = false,
    this.category = ProjectCategory.web,
    this.githubUrl,
    this.liveUrl,
  });
}

class ContactLink {
  final String label;
  final String value;
  final String uri;
  final ContactLinkType? type;

  const ContactLink({
    required this.label,
    required this.value,
    required this.uri,
    this.type,
  });
}

enum ContactLinkType { phone, email, web }

class AboutCard {
  final String icon;
  final String title;
  final String body;
  final Color accent;

  const AboutCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });
}

class ProfileData {
  static const fullName = 'Joshua Hanpil V. Porras';
  static const role = 'Flutter Developer | Tactical Interface Engineer';
  static const headline = 'Information Technology Graduate';
  static const tagline = 'Technical Support & Solutions Engineering';

  // HUD player card fields
  static const overallRating = 87;
  static const position = 'CAM';
  static const nationality = 'PH';
  static const preferredFoot = 'Right';
  static const marketValue = '∞ Potential';

  static const heroCaption =
      'Flagship demo · Flutter web · custom k-means formation detection · physics-based drag';

  static const heroSubcaption =
      'Interactive tactical board built as a portfolio centerpiece — drag players, '
      'scroll to dive, and watch formations update live.';

  static const profileSummary =
      'IT graduate with hands-on experience across systems deployment, network '
      'configuration, technical support, cybersecurity, and full-stack development. '
      'Skilled at troubleshooting complex issues, integrating end-to-end solutions, '
      'and supporting enterprise operations — from infrastructure and hardware repair '
      'to software delivery and project coordination.';

  static const education = [
    (
      school: 'PHINMA University of Iloilo',
      detail:
          'BSIT (Major in Computer Security) · 2022–2026 · Dean\'s Lister 2022–2023',
    ),
    (
      school: 'Cabatuan National Comprehensive High School',
      detail:
          'Senior High: Computer System Servicing (CSS) – With Honors · 2020–2022',
    ),
  ];

  static const aboutCards = [
    AboutCard(
      icon: '⬡',
      title: 'Systems Integrator',
      body:
          'Connects frontend, backend, databases, and deployment into complete '
          'solutions — thinking diagnostically across the full stack.',
      accent: AppColors.primary,
    ),
    AboutCard(
      icon: '◉',
      title: 'Troubleshooting Mindset',
      body:
          'Investigates root causes, gathers information before acting, and fixes '
          'issues across infrastructure, hardware, and software.',
      accent: AppColors.secondary,
    ),
    AboutCard(
      icon: '⟳',
      title: 'Technical Support',
      body:
          'Experience in enterprise operations, hardware diagnostics, network '
          'configuration, and client-facing technical delivery.',
      accent: AppColors.danger,
    ),
    AboutCard(
      icon: '↕',
      title: 'Project Leadership',
      body:
          'Coordinates timelines, translates business needs into functional software, '
          'and delivers outcomes stakeholders can use.',
      accent: AppColors.accent2,
    ),
  ];

  /// Core skill domains for the attribute radar (from self-assessment profile).
  static const hudAttributes = [
    SkillRating(name: 'Troubleshooting', score: 8),
    SkillRating(name: 'Networking', score: 7),
    SkillRating(name: 'Backend', score: 8),
    SkillRating(name: 'Frontend', score: 8),
    SkillRating(name: 'OS Admin', score: 7),
    SkillRating(name: 'Hardware', score: 9),
  ];

  static const ratedSkills = [
    SkillRating(name: 'Windows Troubleshooting', score: 8),
    SkillRating(name: 'Networking', score: 7),
    SkillRating(name: 'Linux Administration', score: 7),
    SkillRating(name: 'Web Development', score: 8),
    SkillRating(name: 'Databases', score: 8),
    SkillRating(name: 'Git / GitHub', score: 7),
  ];

  static const coreCompetencies = [
    'Technical Support',
    'Systems Integration',
    'Hardware Diagnostics',
    'Network Configuration',
    'Infrastructure Deployment',
    'Cybersecurity Operations',
    'Incident Management',
    'Project Coordination',
    'Root Cause Analysis',
    'Client Communication',
  ];

  static const languages = [
    'JavaScript',
    'Python',
    'PHP',
    'Java',
    'Dart',
    'SQL',
    'PowerShell',
    'HTML5 / CSS3',
  ];

  static const frameworks = [
    'Node.js · Express · React',
    'Flutter',
    'Django · Flask',
    'Tailwind · Bootstrap',
    'REST APIs',
  ];

  static const tools = [
    'MySQL · XAMPP/WAMP',
    'Git · GitHub',
    'Linux · Windows Admin',
    'TCP/IP · DNS',
    'JSON · Scripting',
  ];

  static const experience = [
    ExperienceEntry(
      title: 'Editorial Operation (Content Editor) – IT Intern',
      company: 'RELX - Reed Elsevier',
      location: 'Iloilo Business Park, Mandurriao, Iloilo City',
      period: 'Nov 2025 – Mar 2026',
      eventType: MatchEventType.support,
      bullets: [
        'Automated and optimized processing of high-volume legal documentation within a corporate publishing ecosystem, consistently exceeding daily production quotas.',
        'Maintained strict data integrity and quality assurance standards leveraging advanced Microsoft Excel functions and enterprise data management tools.',
      ],
    ),
    ExperienceEntry(
      title: 'Office Assistant',
      company: 'PHINMA University of Iloilo (Campus Finance Office)',
      location: 'Iloilo City',
      period: '2022 – 2026',
      eventType: MatchEventType.deployment,
      bullets: [
        'Managed critical administrative workflows and handled sensitive financial documentation, including secure indexing and archiving of check vouchers.',
        'Executed high-accuracy financial data encoding into internal accounting systems, ensuring operational compliance and streamlined departmental records.',
      ],
    ),
    ExperienceEntry(
      title: 'Hardware Diagnostic & Repair Technician',
      company: 'PHINMA University of Iloilo',
      location: 'Iloilo City',
      period: '2022 – 2025',
      eventType: MatchEventType.hardware,
      bullets: [
        'Provided hardware diagnostics & repair and board-level repair services (soldering, multimeter testing) to restore faulty system components.',
        'Volunteered for university IT infrastructure deployment, overseeing computer laboratory OS imaging, network configuration, and end-to-end live streaming operations.',
      ],
    ),
    ExperienceEntry(
      title: 'Independent Freelance Software Developer & Project Manager',
      company: 'Remote / Various Regions, Philippines',
      location: '',
      period: '2022 – 2025',
      eventType: MatchEventType.freelance,
      bullets: [
        'Gathered client requirements and translated business needs into functional software solutions.',
        'Designed and integrated frontend, backend, and database components for web and desktop applications.',
        'Coordinated project timelines, client communication, and technical delivery across multiple engagements.',
        'Delivered end-to-end solutions while ensuring quality, usability, and stakeholder satisfaction.',
      ],
    ),
  ];

  static const featuredProjects = [
    ProjectEntry(
      name: 'Power Remote',
      subtitle: 'ESP32 Relay Control · Flutter + IoT',
      stack: 'Flutter · ESP32 · HTTP · SQLite · Wi-Fi',
      year: '2025',
      featured: true,
      category: ProjectCategory.flutter,
      accent: AppColors.primary,
      bullets: [
        'Controls an ESP32 relay over local Wi-Fi — ON/OFF, timer presets, and live status polling.',
        'Activity log stored in SQLite; connection guide walks users through AP pairing.',
      ],
    ),
    ProjectEntry(
      name: 'Car4Rent',
      subtitle: 'Car Rental Management · PHP MVC',
      stack: 'PHP · MySQL · HTML/CSS/JS · mysqli',
      year: '2024',
      featured: true,
      category: ProjectCategory.backend,
      accent: AppColors.secondary,
      bullets: [
        'Full MVC architecture: client registration, rental queue, admin dashboard for cars/users.',
        'Learned PHP routing, model layer, and MySQL integration without a framework.',
      ],
    ),
    ProjectEntry(
      name: 'Clean Player',
      subtitle: 'Dark-Themed Media Player · Flutter Desktop',
      stack: 'Flutter · Desktop · Subtitles · EQ',
      year: '2024',
      featured: true,
      category: ProjectCategory.flutter,
      accent: AppColors.accent2,
      bullets: [
        'Minimal dark UI with subtitle styling, audio track selection, and volume enhancement.',
        'Recent files, playlist management, and keyboard shortcuts for desktop.',
      ],
    ),
    ProjectEntry(
      name: 'Bus Ticketing System',
      subtitle: 'Desktop Application · Freelance Project',
      stack: 'Java · MySQL · Thermal Printer Integration',
      year: '2023',
      featured: true,
      category: ProjectCategory.desktop,
      accent: AppColors.warning,
      bullets: [
        'Delivered a client-facing desktop app for bus ticketing and fare management.',
        'Implemented automated discount categories and thermal printer integration.',
      ],
    ),
    ProjectEntry(
      name: 'AE Group Business Site',
      subtitle: 'Multi-Business React Website · Freelance',
      stack: 'React · Vite · Tailwind CSS · React Router',
      year: '2025',
      featured: true,
      category: ProjectCategory.web,
      accent: AppColors.warning,
      bullets: [
        'Multi-page site for Philippine Scapes Realty and AE Food Trading with clean navigation.',
        'Animated particle background, reusable business/product cards, responsive layout.',
      ],
    ),
    ProjectEntry(
      name: 'Network Scanner Tools',
      subtitle: 'Python Network Security Suite',
      stack: 'Python · psutil · scapy · ARP/ICMP',
      year: '2024',
      featured: true,
      category: ProjectCategory.security,
      accent: AppColors.danger,
      bullets: [
        'Collection of scanners: host discovery, OS detection, MAC/vendor lookup, CSV/JSON export.',
        'DDoS monitoring tool with rate limiting, IP blocking, and security event logging.',
      ],
    ),
    ProjectEntry(
      name: 'PSG Fan Site',
      subtitle: 'Multi-Page Football Club Website · 1st Year',
      stack: 'HTML · CSS · JavaScript · Font Awesome',
      year: '2022',
      featured: true,
      category: ProjectCategory.web,
      accent: AppColors.primary,
      bullets: [
        'Static multi-page site: squads, fixtures, merch market, auctions, login UI.',
        'Shared CSS/JS, player tables by role, league standings with highlight links.',
      ],
    ),
    ProjectEntry(
      name: 'Typer.ps1',
      subtitle: 'Human-Like Auto Typer · PowerShell',
      stack: 'PowerShell · SendKeys · Windows',
      year: '2024',
      featured: true,
      category: ProjectCategory.tooling,
      accent: AppColors.secondary,
      bullets: [
        'Simulates keystrokes to bypass paste restrictions in RDP, VDI, and secure terminals.',
        'Configurable delays, randomization, punctuation pauses, and live progress counter.',
      ],
    ),
    ProjectEntry(
      name: 'Lane Ledger',
      subtitle: 'Wild Rift Draft Companion · Lane Matchup Assistant',
      stack: 'React 19 · Vite · TypeScript · JSON',
      year: '2025',
      featured: true,
      category: ProjectCategory.web,
      accent: AppColors.success,
      bullets: [
        'Lightning-fast Wild Rift draft companion for smart ADC/APC (Dragon lane) and full-team pick decisions during champion select.',
        'Almanac for deep champion matchups + Draft Helper with client-side scoring engine (synergies, counters, draft rules, flex picks & warnings).',
        'All data pre-bundled from lane-specific JSON sources — blazing fast and mobile-friendly.',
      ],
      // liveUrl: 'https://lane-matchup-assistant.vercel.app/',
    ),
  ];

  static const projects = [
    ProjectEntry(
      name: 'Enhanced DDoS Monitor',
      subtitle: 'Security Monitoring Web App · Capstone Project',
      stack: 'Python · Flask · JavaScript · Chart.js',
      year: '2025',
      category: ProjectCategory.security,
      bullets: [
        'Designed and implemented a real-time network security monitoring platform capable of detecting abnormal traffic patterns and generating automated threat alerts.',
        'Created a multi-factor threat scoring engine and a dashboard with automated alerts.',
      ],
      accent: AppColors.danger,
    ),
    ProjectEntry(
      name: 'PulsePlanner',
      subtitle: 'Appointment Scheduling System · Academic Project',
      stack: 'Node.js · Express.js · MySQL · EJS',
      year: '2024',
      category: ProjectCategory.backend,
      bullets: [
        'Led development of a multi-role appointment scheduling system supporting Patient, Doctor, and Admin workflows.',
        'Engineered a robust role-based access control system and managed the MySQL schema.',
      ],
      accent: AppColors.secondary,
    ),
    ProjectEntry(
      name: 'Casa Italiana',
      subtitle: 'Hotel & Restaurant Web App · 2nd Year Academic',
      stack: 'PHP · MySQL · HTML/CSS/JS · mysqli',
      year: '2024',
      category: ProjectCategory.backend,
      bullets: [
        'Combined hotel room booking and restaurant ordering with role-based redirects (Member, Admin, S_Admin).',
        'Room reservations update availability; food menu with order status flow (Pending → Accepted → Done).',
      ],
      accent: AppColors.accent2,
    ),
    ProjectEntry(
      name: 'Movie Ticketing System',
      subtitle: 'Java Swing Desktop · Academic Project',
      stack: 'Java · MySQL · Swing · PrinterJob',
      year: '2023',
      category: ProjectCategory.desktop,
      githubUrl: 'https://github.com/Nazonokage/Movie-Ticketing-Project',
      bullets: [
        'CRUD ticket registry with VIP/student/senior/PWD/child discount tiers and 11% VAT on receipts.',
        'JTable management UI, parameterized MySQL inserts, and thermal receipt printing via PrinterJob.',
      ],
      accent: AppColors.accent3,
    ),
  ];

  static List<ProjectEntry> get allProjects => [
        ...featuredProjects,
        ...projects,
      ];

  static const contactLinks = [
    ContactLink(
      label: 'PHONE',
      value: '+63 919 399 3852',
      uri: 'tel:+639193993852',
      type: ContactLinkType.phone,
    ),
    ContactLink(
      label: 'EMAIL',
      value: 'joshinfotech48@gmail.com',
      uri: 'mailto:joshinfotech48@gmail.com',
      type: ContactLinkType.email,
    ),
    ContactLink(
      label: 'LINKEDIN',
      value: 'joshua-valencia-porras',
      uri: 'https://www.linkedin.com/in/joshua-valencia-porras-b1b65238a/',
      type: ContactLinkType.web,
    ),
    ContactLink(
      label: 'PORTFOLIO',
      value: 'jporrasui.jobs180.com',
      uri: 'https://jporrasui.jobs180.com/',
      type: ContactLinkType.web,
    ),
    ContactLink(
      label: 'GITHUB',
      value: 'Nazonokage',
      uri: 'https://github.com/Nazonokage',
      type: ContactLinkType.web,
    ),
    ContactLink(
      label: 'RESUME',
      value: 'Download PDF',
      uri: 'assets/Joshua_resume.pdf',
      type: null,
    ),
  ];
}
