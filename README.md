# BD1-Adopciones – Sistema de Bienestar Animal

**BD1-Adopciones** (Database 1 – Adoptions) is a full‑stack database project for managing an animal‑welfare and adoption system. It combines an **Oracle Database** backend (tables, triggers, packages, jobs, and seed data) with a **JavaFX desktop application** that lets users register pets, handle adoptions, track donations, manage foster homes, and view statistics.

---

## Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Documentation](#documentation)
- [Database Setup](#database-setup)
- [Application Setup (GUI)](#application-setup-gui)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Features
The system covers the following functional areas (as described in the *Manual de Usuario*):

- **Pet management** – register, edit, and query pets, including photos, health status, and location.
- **People management** – adopters, rescuers, veterinarians, and a “blacklist” of unreliable adopters.
- **Foster homes (Casas Cuna)** – manage temporary housing for animals.
- **Adoptions** – record adoptions, follow‑ups, and ratings.
- **Donations & Associations** – track monetary donations and the associations that receive them.
- **Matches** – automatically match pets with potential adopters.
- **Statistics** – generate reports and statistics about the adoption process.
- **Additional queries** – pre‑built queries for deeper analysis.
- **Administration** – manage users, catalogs, parameters, and system logs (admin‑only).
- **Role‑based access** – two roles: *common user* (limited operations) and *administrator* (full access).

---

## Tech Stack
| Layer | Technology |
|-------|------------|
| **Database** | Oracle Database (PL/SQL) – tables, triggers, packages, scheduled jobs, and data‑insertion scripts. |
| **Frontend** | Java 21, JavaFX (controls & FXML), Maven. |
| **Connectivity** | Oracle JDBC driver (`ojdbc11`). |

---

## Repository Structure
The repository is organised into clear, purpose‑specific folders:

```
BD1-Adopciones/
├── App-GUI/                 # JavaFX desktop application (Maven project)
│   ├── src/main/            # Java source code, FXML files, resources
│   ├── .gitignore
│   └── pom.xml              # Maven build file (JavaFX, JDBC dependencies)
├── Data-Insertion/          # SQL scripts to populate initial data
│   ├── Data-Cantones.sql
│   ├── Data-Distritos.sql
│   └── Data-LocationInfo.sql
├── Documentation/           # Design documents, manuals, models
│   ├── CasosPruebaProyectoBD.xlsx        # Test cases
│   ├── DiccionarioDatosProyectoBD.xlsx   # Data dictionary
│   ├── LogoProyectoBD.png                # Project logo
│   ├── Manual de Usuario — Sistema Bienestar Animal.docx / .pdf
│   ├── ModeloConceptualProyectoBD.png    # Conceptual data model
│   └── ModeloLogicoProyectoBD.png        # Logical data model
├── Jobs/                    # Oracle scheduled jobs
│   ├── Jobs-Config-Correos.sql
│   └── Jobs-Creacion-Match.sql
├── Packages/                # PL/SQL package specifications & bodies
│   ├── IdeaDisenioProyectoBD1.txt        # High‑level design notes
│   ├── PKG_ADMINISTRATION_DONATION_ASSOCIATION.sql
│   ├── PKG_ADOPTION_ADMINISTRATION.sql
│   ├── PKG_CATALOG.sql
│   ├── PKG_PARAMETER.sql
│   ├── PKG_PERSON_ADMINISTRATION.sql
│   ├── PKG_PET_ADMINISTRATION.sql
│   ├── PKG_QUERIES_EXTRAS.sql
│   └── PKG_STATISTICS.sql
├── Script-Corrections/      # Patch scripts for packages and auditing
│   ├── actualizar_pkg_*.sql
│   └── complementos_auditoria.sql
├── Tables/                  # DDL for tables and schemas
│   ├── Tablas-ADOPCION_APP.sql
│   ├── Tablas-ADOPCION_APP_MATCH.sql
│   └── Tablas-ADOPCION_AUDIT.SQL
└── Triggers/                # Triggers for auditing and data integrity
    ├── Triggers-Creacion-TablasApp.sql
    ├── Triggers-Modificacion-TablasApp.sql
    └── Triggers-Modificación-Audit.sql
```

---

## Documentation
All design and usage documentation is available in the **`Documentation/`** folder:

- **User manual** (PDF/DOCX) – step‑by‑step guide for end users.
- **Data dictionary** – detailed description of every table and column.
- **Test cases** – scenarios used to validate the system.
- **Conceptual & logical models** – entity‑relationship diagrams.
- **Logo** – project branding.

These files are essential for understanding the database schema and the expected behaviour of the application.

---

## Database Setup
To set up the Oracle database, run the SQL scripts in the following order:

1. **Tables** – create the schema objects:
   ```sql
   @Tables/Tablas-ADOPCION_APP.sql
   @Tables/Tablas-ADOPCION_APP_MATCH.sql
   @Tables/Tablas-ADOPCION_AUDIT.SQL
   ```
2. **Triggers** – add auditing and integrity rules:
   ```sql
   @Triggers/Triggers-Creacion-TablasApp.sql
   @Triggers/Triggers-Modificacion-TablasApp.sql
   @Triggers/Triggers-Modificación-Audit.sql
   ```
3. **Packages** – compile the PL/SQL packages:
   ```sql
   @Packages/PKG_ADMINISTRATION_DONATION_ASSOCIATION.sql
   @Packages/PKG_ADOPTION_ADMINISTRATION.sql
   @Packages/PKG_CATALOG.sql
   @Packages/PKG_PARAMETER.sql
   @Packages/PKG_PERSON_ADMINISTRATION.sql
   @Packages/PKG_PET_ADMINISTRATION.sql
   @Packages/PKG_QUERIES_EXTRAS.sql
   @Packages/PKG_STATISTICS.sql
   ```
4. **Jobs** – schedule background tasks (e.g., match creation, email configuration):
   ```sql
   @Jobs/Jobs-Config-Correos.sql
   @Jobs/Jobs-Creacion-Match.sql
   ```
5. **Initial data** – insert seed data for locations:
   ```sql
   @Data-Insertion/Data-Cantones.sql
   @Data-Insertion/Data-Distritos.sql
   @Data-Insertion/Data-LocationInfo.sql
   ```
6. **Patch scripts** (optional, if you need to apply corrections):
   ```sql
   @Script-Corrections/actualizar_pkg_*.sql
   @Script-Corrections/complementos_auditoria.sql
   ```

> **Note:** The scripts assume an Oracle schema with the appropriate privileges. Adjust the connection settings in your SQL client before running them.

---

## Application Setup (GUI)
The desktop application is a Maven‑based JavaFX project located in **`App-GUI/`**.

### Prerequisites
- **Java 21** (or later) installed.
- **Maven** installed.
- An accessible Oracle database populated with the schema described above.

### Configuration
1. Copy the example database properties file (if provided) to `db.properties` inside the `App-GUI` folder:
   ```bash
   cp App-GUI/db.properties.example App-GUI/db.properties
   ```
2. Edit `db.properties` to point to your Oracle database:
   ```properties
   db.url=jdbc:oracle:thin:@//host:port/service
   db.user=your_username
   db.password=your_password
   ```
   > The original project used **Tailscale** to reach a remote database, but you can configure any Oracle connection string.

### Build & Run
```bash
cd App-GUI
mvn clean javafx:run
```
Alternatively, you can build a fat JAR (if configured) or run the `Main` class directly from your IDE.

---

## Usage
After launching the application:

1. **Log in** with credentials created by an administrator.
2. Use the **side menu** to navigate between modules: *Mascotas, Rescatistas y adoptantes, Casas cuna, Adopciones, Lista negra, Donaciones, Matches, Estadísticas, Consultas adicionales*, etc.
3. **Common users** can modify only the records they created; **administrators** have full access to all data, including catalogs, parameters, users, and the system log.

For detailed usage instructions, refer to the **User Manual** in the `Documentation/` folder.

---

## Contributing
This project appears to be an academic or personal database project. If you wish to contribute, please:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please ensure any new SQL scripts follow the existing naming conventions and include comments where appropriate.

---

## License
No license file is provided in the repository. If you intend to use or distribute this project, please contact the repository owner ([Valverdent](https://github.com/Valverdent)) to clarify licensing terms.

---

*README generated based on the repository structure, the user manual, and the Maven `pom.xml`.*
