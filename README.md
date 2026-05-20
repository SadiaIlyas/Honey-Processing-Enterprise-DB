# Honey Processing Enterprise — Database Management System 🍯

> A fully normalized relational database system designed for an end-to-end honey processing enterprise — covering HR, farm management, hive operations, honey extraction, packaging, warehousing, and distribution.

<p>
  <img src="https://img.shields.io/badge/Database-SQL_Server-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white"/>
  <img src="https://img.shields.io/badge/Design-ERD_%2F_Relational_Model-4479A1?style=flat-square"/>
  <img src="https://img.shields.io/badge/Normalization-3NF-2E8B57?style=flat-square"/>
  <img src="https://img.shields.io/badge/Queries-40_SQL-FF6B35?style=flat-square"/>
  <img src="https://img.shields.io/badge/Tables-40+-5C2D91?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-Complete-2E8B57?style=flat-square"/>
</p>

**GC University Lahore — Department of Computer Science**
Submitted by: **Sadia Ilyas** (0078-BSCS-24) 
Submitted to: Sir Muhammad Hafeez

---

## Project Overview

This project models the complete operational data of a Honey Processing Enterprise using a structured, normalized relational database. The system integrates six major business domains — Human Resources, Farm Management, Hive & Production, Honey Processing, Warehousing & Packaging, and Distribution — into a single cohesive database with enforced referential integrity.

The database was designed from scratch: starting from a natural-language business description, progressing through noun/verb/adjective analysis, unnormalized ERD, normalized ERD (3NF), relational model, and finally full SQL implementation with 40 queries.

---

## System Modules

| Module | Key Entities | Responsibility |
|---|---|---|
| **HR Management** | employee, role, department, section, vacancy, candidate, application, assignment | Manages hiring pipeline, employee records, salary, attendance |
| **Farm Management** | farm, tree, plant, water_resource | Tracks natural resources across farm sites |
| **Hive & Production** | hive, container, hive_placement, hive_harvest, supplier, hive_purchase | Manages bee hives from procurement to harvest |
| **Honey Processing** | honey_batch, test_report, bucket, operation | Extraction, testing, purity classification |
| **Storage & Packaging** | warehouse, storage, package, packaging, packaging_report | Batch storage and packaged product management |
| **Distribution** | distributor, deal, transaction | Distributor deals, payments, delivery |
| **Resource Management** | resource, resource_request, request_detail, resource_allocation | Department-level resource allocation triggered by alerts |
| **Reporting & Alerts** | report, alert, notification | Cross-department reporting and management escalation |

---

## ERD Diagrams

| Diagram | Link |
|---|---|
| Unnormalized ERD | [View on draw.io](https://app.diagrams.net/#G1EVnq3z-QBfo_58QLEfZCj0TtXlfssE7h) |
| Normalized ERD (3NF) | [View on draw.io](https://app.diagrams.net/#G1i3jMoPVQluK9TUtv4lPRomm8gSGXraqz#%7B%22pageId%22%3A%22YSvZLYNHM58EQzchBxSg%22%7D) |

---

## Database Design Methodology

### Step 1 — Requirements Analysis
Business requirements were extracted across 12 functional areas including HR, farm operations, hive management, processing, storage, packaging, distribution, and reporting. Each requirement was mapped to specific entities and constraints.

### Step 2 — Noun / Verb / Adjective Analysis
- **Nouns** → Entities (e.g., employee, hive, honey_batch, warehouse)
- **Verbs** → Relationships (e.g., employee *manages* warehouse, hive *produces* honey_batch)
- **Adjectives** → Attributes with data types and constraints (e.g., purity DECIMAL(5,2), attendance_status CHECK IN ('Present','Absent','Leave'))

### Step 3 — Unnormalized ERD
Initial ERD capturing all entities, relationships, and attributes before normalization — including multi-valued attributes and partial dependencies.

### Step 4 — Normalization to 3NF
- **1NF** — Eliminated multi-valued attributes (e.g., `contact_info`, `supplier_contact`, `distributor_contact` extracted as separate tables)
- **2NF** — Removed partial dependencies from composite-key tables
- **3NF** — Eliminated transitive dependencies (e.g., `net_salary` is computed but retained with a CHECK constraint; role hierarchy separated from employee record)

### Step 5 — Relational Model
40+ tables defined with primary keys, foreign keys, domain constraints (CHECK, UNIQUE, NOT NULL), and composite keys for junction tables.

### Step 6 — SQL Implementation
40 queries implemented covering basic SELECT, filtering, sorting, aggregation (GROUP BY / HAVING), multi-table JOINs (INNER, LEFT), subqueries (correlated and nested), and a CTE-based performance dashboard.

---

## Database Statistics

| Metric | Count |
|---|---|
| Total tables | 40+ |
| Junction / bridge tables | 12 |
| Foreign key relationships | 45+ |
| SQL queries | 40 |
| Reporting queries (with JOINs / subqueries) | 20 |
| Business modules | 8 |

---

## Key SQL Highlights

### Multi-table JOIN — Employee full profile
```sql
SELECT e.employee_name AS Employee,
       d.department_name AS Department,
       s.section_name AS Section,
       r.role_name AS Role,
       m.employee_name AS Manager
FROM employee e
LEFT JOIN department d ON e.department_id = d.department_id
LEFT JOIN section s    ON e.section_id = s.section_id
LEFT JOIN role r       ON e.role_id = r.role_id
LEFT JOIN employee m   ON e.manager_id = m.employee_id;
```

### Correlated subquery — Employees earning above department average
```sql
SELECT e.employee_name, e.department_id, sr.basic_salary
FROM employee e
INNER JOIN salary_record sr ON e.employee_id = sr.employee_id
WHERE sr.basic_salary > (
    SELECT AVG(sr2.basic_salary)
    FROM salary_record sr2
    INNER JOIN employee e2 ON sr2.employee_id = e2.employee_id
    WHERE e2.department_id = e.department_id
    AND sr2.salary_year = 2024
)
AND sr.salary_year = 2024;
```

### CTE — Department-wide performance dashboard
```sql
WITH DepartmentMetrics AS (
    SELECT d.department_id, d.department_name,
           COUNT(DISTINCT e.employee_id) AS TotalEmployees,
           AVG(sr.basic_salary) AS AvgSalary,
           COUNT(DISTINCT dl.deal_id) AS TotalDeals
    FROM department d
    LEFT JOIN employee e       ON d.department_id = e.department_id
    LEFT JOIN salary_record sr ON e.employee_id = sr.employee_id AND sr.salary_year = 2024
    LEFT JOIN deal dl          ON dl.employee_id = e.employee_id
    GROUP BY d.department_id, d.department_name
),
HoneyMetrics AS (
    SELECT d.department_id,
           SUM(hb.quantity)  AS TotalHoneyProduction,
           AVG(tr.purity)    AS AvgPurity
    FROM department d
    LEFT JOIN employee e  ON d.department_id = e.department_id
    LEFT JOIN honey_batch hb ON e.farm_id = hb.bucket_id
    LEFT JOIN test_report tr ON hb.batch_id = tr.batch_id
    GROUP BY d.department_id
)
SELECT dm.department_name,
       dm.TotalEmployees,
       ROUND(dm.AvgSalary, 2)               AS AverageSalary,
       ISNULL(hm.TotalHoneyProduction, 0)   AS TotalHoneyProduced_KG,
       ROUND(ISNULL(hm.AvgPurity, 0), 2)    AS AveragePurity_Percentage,
       CASE WHEN dm.TotalEmployees > 15 THEN 'Large'
            WHEN dm.TotalEmployees > 8  THEN 'Medium'
            ELSE 'Small' END                AS DepartmentSize,
       CASE WHEN ISNULL(hm.AvgPurity,0) >= 98 THEN 'Premium Quality'
            WHEN ISNULL(hm.AvgPurity,0) >= 95 THEN 'Standard Quality'
            ELSE 'Needs Improvement' END    AS QualityRating
FROM DepartmentMetrics dm
LEFT JOIN HoneyMetrics hm ON dm.department_id = hm.department_id
ORDER BY dm.TotalEmployees DESC, hm.AvgPurity DESC;
```

---

## Repository Structure

```
Honey-Processing-Enterprise-DB/
│
├── docs/
│   ├── Project_Report.pdf          ← Full project report
│   ├── ERD_Unnormalized.png        ← Unnormalized ERD diagram
│   └── ERD_Normalized.png          ← Normalized ERD (3NF)
│
├── sql/
│   ├── 01_schema.sql               ← CREATE TABLE statements (all 40+ tables)
│   ├── 02_constraints.sql          ← FK, CHECK, UNIQUE constraints
│   ├── 03_sample_data.sql          ← INSERT statements for testing
│   ├── 04_basic_queries.sql        ← Queries 1–20
│   └── 05_reporting_queries.sql    ← Queries 21–40 (JOINs, subqueries, CTEs)
│
└── README.md
```

---

## Concepts Demonstrated

- **Entity-Relationship Modeling** — identifying entities, relationships (1:1, 1:M, M:N), and attributes from a business narrative
- **Normalization** — 1NF through 3NF; recognising and resolving partial and transitive dependencies
- **Relational Model** — translating ERD into tables with defined PKs, FKs, and domain constraints
- **Data Integrity** — entity integrity (no null PKs), referential integrity (FKs), domain constraints (CHECK, UNIQUE)
- **SQL** — SELECT, WHERE, ORDER BY, GROUP BY, HAVING, INNER/LEFT JOIN, subqueries, correlated subqueries, CTEs
- **Schema Design** — junction tables for M:N relationships, self-referencing FK for employee hierarchy, composite PKs

---

## What I Learned

- How to read a real business description and extract structured data requirements
- Why normalization exists: unnormalized tables cause update anomalies, deletion anomalies, and redundancy — and how each normal form solves a specific class of problem
- That a self-referencing foreign key (`manager_id → employee_id`) is the clean way to model any hierarchy
- Writing CTEs made complex multi-step queries readable — what would have been a 60-line nested subquery became four clearly named blocks
- Data integrity is not optional: a database without constraints is just a spreadsheet

---

## Authors

**Sadia Ilyas** — 0078-BSCS-24 | CS Student @ GCU Lahore
[LinkedIn](https://linkedin.com/in/sadia-ilyas-b96183353) · [GitHub](https://github.com/SadiaIlyas)

**Sumiya Bano Samiullah** — 0052-BSCS-24 | CS Student @ GCU Lahore
