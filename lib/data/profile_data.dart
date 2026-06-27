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

  const ExperienceEntry({
    required this.title,
    required this.company,
    required this.location,
    required this.period,
    required this.bullets,
  });
}

class ProjectEntry {
  final String name;
  final String subtitle;
  final String stack;
  final String year;
  final List<String> bullets;
  final Color accent;

  const ProjectEntry({
    required this.name,
    required this.subtitle,
    required this.stack,
    required this.year,
    required this.bullets,
    required this.accent,
  });
}

class ContactLink {
  final String label;
  final String value;
  final String uri;
  final ContactLinkType type;

  const ContactLink({
    required this.label,
    required this.value,
    required this.uri,
    required this.type,
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
  static const headline = 'Information Technology Graduate';
  static const tagline = 'Technical Support & Solutions Engineering';

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
      detail: 'BSIT (Major in Computer Security) · 2022–2026 · Dean\'s Lister 2022–2023',
    ),
    (
      school: 'Cabatuan National Comprehensive High School',
      detail: 'Senior High: Computer System Servicing (CSS) – With Honors · 2020–2022',
    ),
  ];

  static const aboutCards = [
    AboutCard(
      icon: '⬡',
      title: 'Systems Integrator',
      body:
          'Connects frontend, backend, databases, and deployment into complete '
          'solutions — thinking diagnostically across the full stack.',
      accent: AppColors.neonGlow,
    ),
    AboutCard(
      icon: '◉',
      title: 'Troubleshooting Mindset',
      body:
          'Investigates root causes, gathers information before acting, and fixes '
          'issues across infrastructure, hardware, and software.',
      accent: AppColors.hologram,
    ),
    AboutCard(
      icon: '⟳',
      title: 'Technical Support',
      body:
          'Experience in enterprise operations, hardware diagnostics, network '
          'configuration, and client-facing technical delivery.',
      accent: AppColors.teamB,
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

  static const ratedSkills = [
    SkillRating(name: 'Windows Troubleshooting', score: 8),
    SkillRating(name: 'Networking', score: 7),
    SkillRating(name: 'Linux', score: 7),
    SkillRating(name: 'Web Development', score: 8),
    SkillRating(name: 'Databases', score: 8),
    SkillRating(name: 'Git / GitHub', score: 7),
  ];

  static const coreCompetencies = [
    'Network Configuration',
    'Troubleshooting',
    'Technical Support',
    'Linux Administration',
    'Infrastructure Deployment',
    'Cybersecurity Operations',
    'Project Coordination',
    'Network Security Fundamentals',
    'Vulnerability Assessment',
    'Hardware Diagnostics',
    'Windows Administration',
    'Incident Management',
    'Front-end Development',
    'Secure Software Engineering',
    'TCP/IP',
  ];

  static const languages = [
    'JavaScript',
    'Python',
    'Dart',
    'PHP',
    'Java',
    'SQL',
    'HTML5',
    'CSS3',
    'PowerShell',
  ];

  static const frameworks = [
    'Node.js (Express, EJS, Electron, React)',
    'Django',
    'Flask',
    'Flutter',
    'Tailwind CSS',
    'Bootstrap',
  ];

  static const tools = [
    'MySQL (XAMPP/WAMP)',
    'Git',
    'REST APIs',
    'JSON',
    'PowerShell & Python Scripting',
  ];

  static const experience = [
    ExperienceEntry(
      title: 'Editorial Operation (Content Editor) – IT Intern',
      company: 'RELX - Reed Elsevier',
      location: 'Iloilo Business Park, Mandurriao, Iloilo City',
      period: 'Nov 2025 – Mar 2026',
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
      bullets: [
        'Gathered client requirements and translated business needs into functional software solutions.',
        'Designed and integrated frontend, backend, and database components for web and desktop applications.',
        'Coordinated project timelines, client communication, and technical delivery across multiple engagements.',
        'Delivered end-to-end solutions while ensuring quality, usability, and stakeholder satisfaction.',
      ],
    ),
  ];

  static const projects = [
    ProjectEntry(
      name: 'Enhanced DDoS Monitor',
      subtitle: 'Security Monitoring Web App · Capstone Project',
      stack: 'Python · Flask · JavaScript · Chart.js',
      year: '2025',
      bullets: [
        'Designed and implemented a real-time network security monitoring platform capable of detecting abnormal traffic patterns and generating automated threat alerts.',
        'Created a multi-factor threat scoring engine and a dashboard with automated alerts.',
      ],
      accent: AppColors.teamB,
    ),
    ProjectEntry(
      name: 'PulsePlanner',
      subtitle: 'Appointment Scheduling System · Academic Project',
      stack: 'Node.js · Express.js · MySQL · EJS',
      year: '2024',
      bullets: [
        'Led development of a multi-role appointment scheduling system supporting Patient, Doctor, and Admin workflows.',
        'Engineered a robust role-based access control system and managed the MySQL schema.',
      ],
      accent: AppColors.hologram,
    ),
    ProjectEntry(
      name: 'Bus Ticketing System',
      subtitle: 'Desktop Application · Academic Project',
      stack: 'Java · MySQL · Thermal Printer Integration',
      year: '2023',
      bullets: [
        'Developed a desktop application for bus ticketing and fare management.',
        'Implemented automated discount categories and thermal printer integration.',
      ],
      accent: AppColors.accent3,
    ),
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
  ];
}
