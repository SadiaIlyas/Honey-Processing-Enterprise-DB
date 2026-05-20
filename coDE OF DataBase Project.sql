CREATE DATABASE Honey_Processing_Enterprisee;
GO

USE Honey_Processing_Enterprisee;

--=========================
-- ROLE
-- =========================
CREATE TABLE role (
    role_id VARCHAR(20) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    role_description VARCHAR(MAX)
);


-- FARM
CREATE TABLE Farm (
    farm_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(150) NOT NULL,
    area DECIMAL(10,2) CHECK (area > 0)
);


-- =========================
-- DEPARTMENT
-- =========================
CREATE TABLE department (
    department_id VARCHAR(20) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_location VARCHAR(100) NOT NULL,
    department_email VARCHAR(100) UNIQUE,
    manager_id VARCHAR(20)
);
-- =========================
-- SECTION
-- =========================
CREATE TABLE section (
    section_id VARCHAR(20) PRIMARY KEY,
    section_name VARCHAR(100) NOT NULL,
    department_id VARCHAR(20) NOT NULL,
    section_manager_id VARCHAR(20),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =========================
-- EMPLOYEE
-- =========================
CREATE TABLE employee (
    employee_id VARCHAR(20) PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    employee_email VARCHAR(100) UNIQUE NOT NULL,
    employee_phone VARCHAR(20) UNIQUE NOT NULL,
    employee_hire_date DATE NOT NULL,
    department_id VARCHAR(20),
    section_id VARCHAR(20),
    role_id VARCHAR(20),
    manager_id VARCHAR(20),
    farm_id INT,
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (section_id) REFERENCES section(section_id),
    FOREIGN KEY (role_id) REFERENCES role(role_id),
    FOREIGN KEY (manager_id) REFERENCES employee(employee_id)
);


-- =========================
-- ADD FOREIGN KEYS FOR MANAGERS
-- =========================
ALTER TABLE department ADD FOREIGN KEY (manager_id) REFERENCES employee(employee_id);


ALTER TABLE section ADD FOREIGN KEY (section_manager_id) REFERENCES employee(employee_id);


-- =========================
-- CONTACT INFO (MULTI-VALUED)
-- =========================
CREATE TABLE contact_info (
    employee_id VARCHAR(20),
    phone_number VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    PRIMARY KEY (employee_id, phone_number),
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE CASCADE
);

-- =========================
-- SALARY RECORD
-- =========================
CREATE TABLE salary_record (
    employee_id VARCHAR(20),
    salary_month INT CHECK (salary_month BETWEEN 1 AND 12),
    salary_year INT CHECK (salary_year >= 2000),
    basic_salary DECIMAL(10,2) NOT NULL CHECK (basic_salary >= 0),
    bonus DECIMAL(10,2) DEFAULT 0 CHECK (bonus >= 0),
    deduction DECIMAL(10,2) DEFAULT 0 CHECK (deduction >= 0),
    net_salary DECIMAL(10,2) NOT NULL CHECK (net_salary >= 0),
    PRIMARY KEY (employee_id, salary_month, salary_year),
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE CASCADE
);


-- =========================
-- ATTENDANCE
-- =========================
CREATE TABLE attendance_record (
    employee_id VARCHAR(20),
    attendance_date DATE,
    working_hours DECIMAL(4,2) CHECK (working_hours >= 0),
    attendance_status VARCHAR(20)
        CHECK (attendance_status IN ('Present','Absent','Leave')),
    PRIMARY KEY (employee_id, attendance_date),
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE CASCADE
);

-- =========================
-- TRANSACTION
-- =========================
CREATE TABLE salary_transaction (
    employee_id VARCHAR(20),
    salary_month INT,
    salary_year INT,
    transaction_date DATE NOT NULL,
    transaction_amount DECIMAL(10,2) NOT NULL CHECK (transaction_amount >= 0),
    transaction_method VARCHAR(20)
        CHECK (transaction_method IN ('Cash','Bank','Online')),
    PRIMARY KEY (employee_id, salary_month, salary_year),
    FOREIGN KEY (employee_id, salary_month, salary_year)
        REFERENCES salary_record(employee_id, salary_month, salary_year)
        ON DELETE CASCADE
);


-- =========================
-- REPORT
-- =========================
CREATE TABLE report (
    report_id VARCHAR(20) PRIMARY KEY,
    department_id VARCHAR(20),
    employee_id VARCHAR(20),
    report_date DATE NOT NULL,
    report_type VARCHAR(50),
    report_content VARCHAR(MAX),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE CASCADE,
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE SET NULL
);


-- =========================
-- ALERT
-- =========================
CREATE TABLE alert (
    alert_id VARCHAR(20) PRIMARY KEY,
    report_id VARCHAR(20),
    employee_id VARCHAR(20),
    alert_type VARCHAR(50),
    alert_description VARCHAR(MAX),
    alert_date DATE,
    FOREIGN KEY (report_id)
        REFERENCES report(report_id)
        ON DELETE CASCADE
);


-- =========================
-- NOTIFICATION
-- =========================
CREATE TABLE notification (
    notification_id VARCHAR(20) PRIMARY KEY,
    alert_id VARCHAR(20),
    department_id VARCHAR(20),
    notification_type VARCHAR(20)
        CHECK (notification_type IN ('HR','RESOURCE')),
    message VARCHAR(MAX),
    notify_date DATE,
    FOREIGN KEY (alert_id)
        REFERENCES alert(alert_id)
        ON DELETE NO ACTION,
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON DELETE NO ACTION
);


-- =========================
-- VACANCY
-- =========================
CREATE TABLE vacancy (
    vacancy_id VARCHAR(20) PRIMARY KEY,
    department_id VARCHAR(20),
    role_id VARCHAR(20),
    notification_id VARCHAR(20),
    created_by_employee_id VARCHAR(20),
    vacancy_status VARCHAR(20)
        CHECK (vacancy_status IN ('Open','Closed')),
    description VARCHAR(MAX),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id),
    FOREIGN KEY (role_id)
        REFERENCES role(role_id),
    FOREIGN KEY (notification_id)
        REFERENCES notification(notification_id),
    FOREIGN KEY (created_by_employee_id)
        REFERENCES employee(employee_id)
);
alter table vacancy add   created_date Date

-- =========================
-- CANDIDATE
-- =========================
CREATE TABLE candidate (
    candidate_id VARCHAR(20) PRIMARY KEY,
    candidate_name VARCHAR(100) NOT NULL,
    candidate_email VARCHAR(100) UNIQUE,
    candidate_phone VARCHAR(20),
    qualification VARCHAR(MAX),
    cv_link VARCHAR(MAX),
    experience INT CHECK (experience >= 0)
);


-- =========================
-- APPLICATION (JUNCTION)
-- =========================
CREATE TABLE application (
    candidate_id VARCHAR(20),
    vacancy_id VARCHAR(20),
    apply_date DATE,
    application_status VARCHAR(20),
    PRIMARY KEY (candidate_id, vacancy_id),
    FOREIGN KEY (candidate_id)
        REFERENCES candidate(candidate_id)
        ON DELETE CASCADE,
    FOREIGN KEY (vacancy_id)
        REFERENCES vacancy(vacancy_id)
        ON DELETE CASCADE
);


-- =========================
-- ASSIGNMENT
-- =========================
CREATE TABLE assignment (
    candidate_id VARCHAR(20),
    vacancy_id VARCHAR(20),
    employee_id VARCHAR(20),
    department_id VARCHAR(20),
    role_id VARCHAR(20),
    joining_date DATE,
    PRIMARY KEY (candidate_id, vacancy_id),
    FOREIGN KEY (candidate_id, vacancy_id)
        REFERENCES application(candidate_id, vacancy_id),
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id),
    FOREIGN KEY (role_id)
        REFERENCES role(role_id)
);

-- =========================
-- RESOURCE
-- =========================
CREATE TABLE resource (
    resource_id VARCHAR(20) PRIMARY KEY,
    resource_name VARCHAR(100),
    unit VARCHAR(50),
    status VARCHAR(20)
);

-- =========================
-- RESOURCE REQUEST
-- =========================
CREATE TABLE resource_request (
    request_id VARCHAR(20) PRIMARY KEY,
    department_id VARCHAR(20),
    alert_id VARCHAR(20),
    request_date DATE,
    request_status VARCHAR(20),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id),
    FOREIGN KEY (alert_id)
        REFERENCES alert(alert_id)
);


-- =========================
-- REQUEST DETAIL (JUNCTION)
-- =========================
CREATE TABLE request_detail (
    request_id VARCHAR(20),
    resource_id VARCHAR(20),
    quantity DECIMAL(10,2) CHECK (quantity > 0),
    PRIMARY KEY (request_id, resource_id),
    FOREIGN KEY (request_id)
        REFERENCES resource_request(request_id)
        ON DELETE CASCADE,
    FOREIGN KEY (resource_id)
        REFERENCES resource(resource_id)
        ON DELETE CASCADE
);


-- =========================
-- RESOURCE ALLOCATION
-- =========================
CREATE TABLE resource_allocation (
    request_id VARCHAR(20),
    resource_id VARCHAR(20),
    department_id VARCHAR(20),
    allocated_quantity DECIMAL(10,2) CHECK (allocated_quantity > 0),
    allocation_date DATE,
    PRIMARY KEY (request_id, resource_id),
    FOREIGN KEY (request_id, resource_id)
        REFERENCES request_detail(request_id, resource_id),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
);


-- =========================
-- BUCKET
-- =========================
CREATE TABLE Bucket (
    bucket_id INT PRIMARY KEY,
    bucket_size VARCHAR(50) NOT NULL
);

-- =========================
-- HONEY BATCH
-- =========================
CREATE TABLE honey_batch (
    batch_id VARCHAR(20) PRIMARY KEY,
    quantity DECIMAL(10,2),
    received_date DATE,
    bucket_id INT,
    FOREIGN KEY (bucket_id) REFERENCES Bucket(bucket_id)
);


-- =========================
-- TEST REPORT
-- =========================
CREATE TABLE test_report (
    test_report_id VARCHAR(20) PRIMARY KEY,
    batch_id VARCHAR(20),
    report_id VARCHAR(20),
    purity DECIMAL(5,2),
    category VARCHAR(20),
    test_date DATE,
    FOREIGN KEY (batch_id)
        REFERENCES honey_batch(batch_id)
        ON DELETE CASCADE,
    FOREIGN KEY (report_id)
        REFERENCES report(report_id)
);


-- =========================
-- WAREHOUSE
-- =========================
CREATE TABLE warehouse (
    warehouse_id VARCHAR(20) PRIMARY KEY,
    location VARCHAR(100),
    manager_id VARCHAR(20),
    FOREIGN KEY (manager_id)
        REFERENCES employee(employee_id)
        ON DELETE SET NULL
);

-- =========================
-- STORAGE (JUNCTION)
-- =========================
CREATE TABLE storage (
    batch_id VARCHAR(20),
    warehouse_id VARCHAR(20),
    quantity DECIMAL(10,2),
    storage_date DATE,
    PRIMARY KEY (batch_id, warehouse_id),
    FOREIGN KEY (batch_id)
        REFERENCES honey_batch(batch_id)
        ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id)
        REFERENCES warehouse(warehouse_id)
        ON DELETE CASCADE
);


-- =========================
-- DISTRIBUTOR
-- =========================
CREATE TABLE Distributor (
    distributor_id INT PRIMARY KEY,
    distributor_name VARCHAR(100) NOT NULL,
    distributor_cnic VARCHAR(15) UNIQUE NOT NULL
);


-- =========================
-- PACKAGE
-- =========================
CREATE TABLE package (
    package_id VARCHAR(20) PRIMARY KEY,
    size VARCHAR(20),
    type VARCHAR(50),
    price DECIMAL(10,2),
    distributor_id INT,
    FOREIGN KEY (distributor_id) REFERENCES Distributor(distributor_id)
);


-- =========================
-- PACKAGING (JUNCTION)
-- =========================
CREATE TABLE packaging (
    batch_id VARCHAR(20),
    package_id VARCHAR(20),
    employee_id VARCHAR(20),
    packaging_date DATE,
    quantity DECIMAL(10,2),
    PRIMARY KEY (batch_id, package_id, packaging_date),
    FOREIGN KEY (batch_id)
        REFERENCES honey_batch(batch_id)
        ON DELETE CASCADE,
    FOREIGN KEY (package_id)
        REFERENCES package(package_id)
        ON DELETE CASCADE,
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE SET NULL
);


-- =========================
-- PACKAGING REPORT
-- =========================
CREATE TABLE packaging_report (
    packaging_report_id VARCHAR(20) PRIMARY KEY,
    manager_id VARCHAR(20),
    batch_id VARCHAR(20),
    total_batches INT,
    total_packages INT,
    report_date DATE,
    FOREIGN KEY (manager_id)
        REFERENCES employee(employee_id)
        ON DELETE SET NULL,
    FOREIGN KEY (batch_id)
        REFERENCES honey_batch(batch_id)
);


--=====================
-- TREE
--=====================
CREATE TABLE Tree (
    tree_id INT PRIMARY KEY,
    farm_id INT NOT NULL,
    tree_water_consumption DECIMAL(8,2) CHECK (tree_water_consumption >= 0),
    tree_height DECIMAL(6,2) CHECK (tree_height > 0),
    tree_location VARCHAR(100),
    tree_plantation_date DATE NOT NULL,
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id)
);

-- PLANT
CREATE TABLE Plant (
    plant_id INT PRIMARY KEY,
    farm_id INT NOT NULL,
    plant_type VARCHAR(50) NOT NULL,
    plant_plantation_date DATE NOT NULL,
    plant_location VARCHAR(100),
    plant_water_consumption DECIMAL(8,2) CHECK (plant_water_consumption >= 0),
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id)
);

-- WATER RESOURCE
CREATE TABLE Water_Resource (
    water_resource_id INT PRIMARY KEY,
    farm_id INT NOT NULL,
    water_resource_type VARCHAR(50) NOT NULL,
    water_resource_area DECIMAL(10,2),
    water_resource_capacity DECIMAL(10,2) CHECK (water_resource_capacity >= 0),
    water_resource_current_water_level DECIMAL(10,2) CHECK (water_resource_current_water_level >= 0),
    water_resource_location VARCHAR(100),
    FOREIGN KEY (farm_id) REFERENCES Farm(farm_id)
);


-- CONTAINER
CREATE TABLE Container (
    container_id INT PRIMARY KEY,
    container_size VARCHAR(50) NOT NULL
);

-- HIVE
CREATE TABLE Hive (
    hive_id INT PRIMARY KEY,
    hive_worker_bees INT CHECK (hive_worker_bees >= 0),
    hive_brood INT CHECK (hive_brood >= 0),
    container_id INT,
    hive_honey DECIMAL(10,2) CHECK (hive_honey >= 0),
    hive_queen_bee VARCHAR(50),
    FOREIGN KEY (container_id) REFERENCES Container(container_id)
);


-- REPORT RECEIVER
CREATE TABLE ReportReceiver (
    report_receiver_id INT,
    employee_id VARCHAR(20),
    report_date DATE NOT NULL,
    report_content VARCHAR(MAX),
    report_status VARCHAR(50),
    PRIMARY KEY (report_receiver_id, employee_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

-- DEPARTMENT MANAGER
CREATE TABLE DepartmentManager (
    department_id VARCHAR(20),
    employee_id VARCHAR(20),
    PRIMARY KEY (department_id, employee_id),
    year INT CHECK (year >= 2000),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);



-- HIVE PLACEMENT
CREATE TABLE Hive_Placement (
    hive_placement_id INT PRIMARY KEY,
    hive_id INT NOT NULL,
    tree_id INT NOT NULL,
    employee_id VARCHAR(20) NOT NULL,
    hive_placement_date DATE NOT NULL,
    FOREIGN KEY (hive_id) REFERENCES Hive(hive_id),
    FOREIGN KEY (tree_id) REFERENCES Tree(tree_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);


-- HIVE HARVEST
CREATE TABLE Hive_Harvest (
    harvest_id INT PRIMARY KEY,
    hive_id INT NOT NULL,
    employee_id VARCHAR(20) NOT NULL,
    container_id INT NOT NULL,
    hive_harvest_date DATE NOT NULL,
    FOREIGN KEY (hive_id) REFERENCES Hive(hive_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    FOREIGN KEY (container_id) REFERENCES Container(container_id)
);

-- OPERATION
CREATE TABLE Operation (
    operation_id INT PRIMARY KEY,
    operation_name VARCHAR(100) NOT NULL,
    operation_date DATE NOT NULL,
    operation_result VARCHAR(100),
    employee_id VARCHAR(20),
    hive_id INT,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    FOREIGN KEY (hive_id) REFERENCES Hive(hive_id)
);

-- SUPPLIER
CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_cnic VARCHAR(15) UNIQUE NOT NULL
);


-- SUPPLIER CONTACT
CREATE TABLE SupplierContact (
    supplier_id INT,
    supplier_phone VARCHAR(20),
    PRIMARY KEY (supplier_id, supplier_phone),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);


-- HIVE PURCHASE
CREATE TABLE Hive_Purchase (
    hive_purchase_id INT PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL,
    supplier_id INT NOT NULL,
    hive_purchase_date DATE NOT NULL,
    hive_purchase_quantity INT CHECK (hive_purchase_quantity > 0),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);


-- DISTRIBUTOR CONTACT
CREATE TABLE DistributorContact (
    distributor_id INT,
    distributor_phone VARCHAR(20),
    PRIMARY KEY (distributor_id, distributor_phone),
    FOREIGN KEY (distributor_id) REFERENCES Distributor(distributor_id)
);


-- DEAL
CREATE TABLE Deal (
    deal_id INT PRIMARY KEY,
    price_per_kilogram DECIMAL(10,2) CHECK (price_per_kilogram > 0),
    deal_date DATE NOT NULL,
    deal_total_amount DECIMAL(12,2) CHECK (deal_total_amount >= 0),
    distributor_id INT,
    employee_id VARCHAR(20),
    FOREIGN KEY (distributor_id) REFERENCES Distributor(distributor_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);


-- TRANSACTION (for deals)
CREATE TABLE Transaction_Deal (
    transaction_id INT PRIMARY KEY,
    transaction_method VARCHAR(50) NOT NULL,
    transaction_amount DECIMAL(12,2) CHECK (transaction_amount >= 0),
    transaction_date DATE NOT NULL,
    deal_id INT,
    FOREIGN KEY (deal_id) REFERENCES Deal(deal_id)
);


-- NOTIFICATION (for distributor transactions)
CREATE TABLE disNotification (
    notification_id INT PRIMARY KEY,
    transaction_id INT,
    receiver_id VARCHAR(20),
    sender_id VARCHAR(20),
    FOREIGN KEY (transaction_id) REFERENCES Transaction_Deal(transaction_id),
    FOREIGN KEY (receiver_id) REFERENCES employee(employee_id),
    FOREIGN KEY (sender_id) REFERENCES employee(employee_id)
);


-- BUCKET PLACEMENT
CREATE TABLE Bucket_Placement (
    bucket_placement_id INT PRIMARY KEY,
    bucket_id INT NOT NULL,
    warehouse_id VARCHAR(20),
    employee_id VARCHAR(20),
    bucket_placement_date DATE NOT NULL,
    FOREIGN KEY (bucket_id) REFERENCES Bucket(bucket_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

INSERT INTO department (department_id, department_name, department_location, department_email) VALUES
('D001', 'Farm Management Department', 'Farm Administration Building', 'farm.management@honey.com'),
('D002', 'Honey Processing Department', 'Processing Facility Building A', 'processing@honey.com'),
('D003', 'Sales Department', 'Sales Office Building B', 'sales@honey.com'),
('D004', 'HR Department', 'HR Office Building C', 'hr@honey.com'),
('D005', 'Packing Department', 'Packing Facility Building D', 'packing@honey.com'),
('D006', 'Resource Management Department', 'Resource Management Building E', 'resource@honey.com');
INSERT INTO section (section_id, section_name, department_id) VALUES
('SEC001', 'Hive Uncapping Section', 'D002'),
('SEC002', 'Honey Extracting Section', 'D002'),
('SEC003', 'Honey Bucketing Section', 'D002'),
('SEC004', 'Honey Testing Section', 'D002'),
('SEC005', 'Employee Management Section', 'D004'),
('SEC006', 'Recruitment Section', 'D004');


 RECORDS IN ROLE TABLE
INSERT INTO role (role_id, role_name, role_description) VALUES
('R001', 'CEO', 'Chief Executive Officer - Overall company leadership'),
('R002', 'Department Manager', 'Manages complete department operations and staff'),
('R003', 'Section Manager', 'Oversees specific section within a department'),
('R004', 'Farm Manager', 'Manages farm operations and beekeeping activities'),
('R005', 'Honey Processing Manager', 'Supervises honey processing operations'),
('R006', 'Quality Control Specialist', 'Tests honey quality and maintains standards'),
('R007', 'Hive Technician', 'Maintains and inspects beehives'),
('R008', 'Extraction Operator', 'Operates honey extraction machinery'),
('R009', 'Packing Supervisor', 'Supervises honey packing operations'),
('R010', 'Sales Manager', 'Manages sales team and client relationships'),
('R011', 'Sales Executive', 'Handles customer orders and sales'),
('R012', 'HR Manager', 'Manages human resources department'),
('R013', 'Recruitment Officer', 'Handles recruitment and hiring process'),
('R014', 'Payroll Officer', 'Manages employee salary and benefits'),
('R015', 'Resource Manager', 'Manages company resources and inventory'),
('R016', 'Warehouse Keeper', 'Manages warehouse and storage operations'),
('R017', 'Lab Technician', 'Performs honey testing in laboratory'),
('R018', 'Accountant', 'Handles financial transactions and records'),
('R019', 'Driver', 'Transports honey and materials'),
('R020', 'General Worker', 'Performs general operational tasks');

-- =========================
-- 25 RECORDS FOR FARM TABLE
-- =========================
INSERT INTO Farm (farm_id, name, location, area) VALUES
(1, 'Green Valley Farm', 'North Region, District A', 150.75),
(2, 'Sunrise Honey Farm', 'East Region, District B', 200.50),
(3, 'Mountain View Farm', 'West Region, District C', 175.25),
(4, 'River Side Farm', 'South Region, District D', 120.00),
(5, 'Organic Bee Farm', 'North Region, District E', 95.50),
(6, 'Wildflower Farm', 'East Region, District F', 180.00),
(7, 'Golden Honey Farm', 'West Region, District G', 210.30),
(8, 'Blue Sky Farm', 'South Region, District H', 145.80),
(9, 'Forest Edge Farm', 'North Region, District I', 165.40),
(10, 'Meadow Brook Farm', 'East Region, District J', 130.25),
(11, 'Clover Field Farm', 'West Region, District K', 190.60),
(12, 'Pine Valley Farm', 'South Region, District L', 110.75),
(13, 'Cedar Hill Farm', 'North Region, District M', 225.00),
(14, 'Maple Grove Farm', 'East Region, District N', 155.50),
(15, 'Oak Meadow Farm', 'West Region, District O', 185.90),
(16, 'Willow Creek Farm', 'South Region, District P', 140.25),
(17, 'Birch Wood Farm', 'North Region, District Q', 170.35),
(18, 'Aspen Grove Farm', 'East Region, District R', 195.45),
(19, 'Chestnut Hill Farm', 'West Region, District S', 160.55),
(20, 'Hawthorn Farm', 'South Region, District T', 125.65),
(21, 'Lavender Fields Farm', 'North Region, District U', 205.75),
(22, 'Sunflower Farm', 'East Region, District V', 230.85),
(23, 'Rose Garden Farm', 'West Region, District W', 145.95),
(24, 'Jasmine Valley Farm', 'South Region, District X', 175.05),
(25, 'Lotus Pond Farm', 'North Region, District Y', 198.15);

-- =========================
-- 25 RECORDS FOR BUCKET TABLE
-- =========================
INSERT INTO Bucket (bucket_id, bucket_size) VALUES
(1, '1 Liter'),
(2, '2 Liters'),
(3, '3 Liters'),
(4, '4 Liters'),
(5, '5 Liters'),
(6, '6 Liters'),
(7, '7 Liters'),
(8, '8 Liters'),
(9, '9 Liters'),
(10, '10 Liters'),
(11, '12 Liters'),
(12, '15 Liters'),
(13, '18 Liters'),
(14, '20 Liters'),
(15, '25 Liters'),
(16, '30 Liters'),
(17, '35 Liters'),
(18, '40 Liters'),
(19, '45 Liters'),
(20, '50 Liters'),
(21, '60 Liters'),
(22, '75 Liters'),
(23, '80 Liters'),
(24, '90 Liters'),
(25, '100 Liters');

-- =========================
-- 25 RECORDS FOR CONTAINER TABLE
-- =========================
INSERT INTO Container (container_id, container_size) VALUES
(1, 'Small - 5L'),
(2, 'Small - 10L'),
(3, 'Medium - 15L'),
(4, 'Medium - 20L'),
(5, 'Medium - 25L'),
(6, 'Large - 30L'),
(7, 'Large - 35L'),
(8, 'Large - 40L'),
(9, 'XL - 45L'),
(10, 'XL - 50L'),
(11, 'XXL - 60L'),
(12, 'XXL - 70L'),
(13, 'XXXL - 80L'),
(14, 'XXXL - 90L'),
(15, 'Jumbo - 100L'),
(16, 'Jumbo - 120L'),
(17, 'Jumbo - 150L'),
(18, 'Industrial - 200L'),
(19, 'Industrial - 250L'),
(20, 'Industrial - 300L'),
(21, 'Bulk - 400L'),
(22, 'Bulk - 500L'),
(23, 'Bulk - 750L'),
(24, 'Bulk - 1000L'),
(25, 'Tank - 2000L');

-- =========================
-- 25 RECORDS FOR RESOURCE TABLE
-- =========================
INSERT INTO resource (resource_id, resource_name, unit, status) VALUES
('RES001', 'Protective Suit', 'pieces', 'Available'),
('RES002', 'Safety Gloves', 'pairs', 'Available'),
('RES003', 'Safety Goggles', 'pieces', 'Available'),
('RES004', 'Face Mask', 'pieces', 'Available'),
('RES005', 'Rubber Boots', 'pairs', 'Available'),
('RES006', 'Honey Extractor Machine', 'units', 'Available'),
('RES007', 'Uncapping Knife', 'pieces', 'Available'),
('RES008', 'Honey Strainer', 'pieces', 'Available'),
('RES009', 'Honey Settling Tank', 'units', 'Available'),
('RES010', 'Bottle Filling Machine', 'units', 'Available'),
('RES011', 'Labeling Machine', 'units', 'Available'),
('RES012', 'Sealing Machine', 'units', 'Available'),
('RES013', 'Refractometer', 'pieces', 'Available'),
('RES014', 'pH Meter', 'pieces', 'Available'),
('RES015', 'Digital Scale', 'pieces', 'Available'),
('RES016', 'Warehouse Rack', 'units', 'Available'),
('RES017', 'Forklift', 'units', 'Available'),
('RES018', 'Pallet Jack', 'units', 'Available'),
('RES019', 'Cleaning Kit', 'kits', 'Available'),
('RES020', 'Sanitizer Spray', 'bottles', 'Available'),
('RES021', 'First Aid Kit', 'kits', 'Available'),
('RES022', 'Fire Extinguisher', 'units', 'Available'),
('RES023', 'Computer System', 'units', 'Available'),
('RES024', 'Printer', 'units', 'Available'),
('RES025', 'Office Furniture Set', 'sets', 'Available');

-- =========================
-- 25 RECORDS FOR DISTRIBUTOR TABLE
-- =========================
INSERT INTO Distributor (distributor_id, distributor_name, distributor_cnic) VALUES
(1, 'Sweet Honey Distributors', '12345-6789012-3'),
(2, 'Pure Honey Traders', '12345-6789013-1'),
(3, 'Golden Drop Enterprises', '12345-6789014-9'),
(4, 'Honey World International', '12345-6789015-7'),
(5, 'Natural Sweetness Ltd', '12345-6789016-5'),
(6, 'Bee Natural Products', '12345-6789017-3'),
(7, 'Organic Honey Supplies', '12345-6789018-1'),
(8, 'Mountain Honey Distributors', '12345-6789019-0'),
(9, 'Valley Fresh Honey', '12345-6789020-8'),
(10, 'Royal Honey Traders', '12345-6789021-6'),
(11, 'Elite Honey Products', '12345-6789022-4'),
(12, 'Prime Honey Solutions', '12345-6789023-2'),
(13, 'Star Honey International', '12345-6789024-0'),
(14, 'United Honey Distributors', '12345-6789025-9'),
(15, 'Global Honey Network', '12345-6789026-7'),
(16, 'Pacific Honey Trading', '12345-6789027-5'),
(17, 'Atlantic Honey Supplies', '12345-6789028-3'),
(18, 'Desert Bloom Honey', '12345-6789029-1'),
(19, 'Rainforest Honey Co', '12345-6789030-5'),
(20, 'Arctic Pure Honey', '12345-6789031-3'),
(21, 'Urban Honey Market', '12345-6789032-1'),
(22, 'Rural Honey Distributors', '12345-6789033-0'),
(23, 'Farm Fresh Honey', '12345-6789034-8'),
(24, 'Heritage Honey Traders', '12345-6789035-6'),
(25, 'Premium Honey Exports', '12345-6789036-4');

-- =========================
-- 25 RECORDS FOR SUPPLIER TABLE
-- =========================
INSERT INTO Supplier (supplier_id, supplier_name, supplier_cnic) VALUES
(1, 'Bee Equipment Supplies', '22345-6789012-3'),
(2, 'Hive Tools International', '22345-6789013-1'),
(3, 'Apiculture Solutions Ltd', '22345-6789014-9'),
(4, 'Beekeeping Essentials', '22345-6789015-7'),
(5, 'Honey Processing Equipments', '22345-6789016-5'),
(6, 'Packaging Materials Co', '22345-6789017-3'),
(7, 'Glass Bottle Suppliers', '22345-6789018-1'),
(8, 'Plastic Container Inc', '22345-6789019-0'),
(9, 'Label Printing Services', '22345-6789020-8'),
(10, 'Chemical Supplies Ltd', '22345-6789021-6'),
(11, 'Cleaning Products Co', '22345-6789022-4'),
(12, 'Safety Equipment Supply', '22345-6789023-2'),
(13, 'Uniforms & Apparel', '22345-6789024-0'),
(14, 'Office Supplies Depot', '22345-6789025-9'),
(15, 'Technology Solutions', '22345-6789026-7'),
(16, 'Vehicle Services Co', '22345-6789027-5'),
(17, 'Fuel & Lubricants Ltd', '22345-6789028-3'),
(18, 'Maintenance Tools Inc', '22345-6789029-1'),
(19, 'Raw Honey Suppliers', '22345-6789030-5'),
(20, 'Organic Honey Farms', '22345-6789031-3'),
(21, 'Pollen & Propolis Co', '22345-6789032-1'),
(22, 'Wax Processing Ltd', '22345-6789033-0'),
(23, 'Royal Jelly Supplies', '22345-6789034-8'),
(24, 'Bee Venom Extractors', '22345-6789035-6'),
(25, 'Beekeeping Training Services', '22345-6789036-2');

USE Honey_Processing_Enterprise;

-- =========================
-- 70 RECORDS FOR EMPLOYEE TABLE
-- =========================
INSERT INTO employee (employee_id, employee_name, employee_email, employee_phone, employee_hire_date, department_id, section_id, role_id, manager_id, farm_id) VALUES
('EMP001', 'John Smith', 'john.smith@honey.com', '03001111111', '2020-01-15', 'D001', NULL, 'R002', NULL, 1),
('EMP002', 'Sarah Johnson', 'sarah.johnson@honey.com', '03002222222', '2020-02-20', 'D002', NULL, 'R002', NULL, 2),
('EMP003', 'Michael Brown', 'michael.brown@honey.com', '03003333333', '2020-03-10', 'D003', NULL, 'R002', NULL, 3),
('EMP004', 'Emily Davis', 'emily.davis@honey.com', '03004444444', '2020-04-05', 'D004', NULL, 'R002', NULL, 4),
('EMP005', 'David Wilson', 'david.wilson@honey.com', '03005555555', '2020-05-12', 'D005', NULL, 'R002', NULL, 5),
('EMP006', 'Lisa Anderson', 'lisa.anderson@honey.com', '03006666666', '2020-06-18', 'D006', NULL, 'R002', NULL, 6),
('EMP007', 'Robert Taylor', 'robert.taylor@honey.com', '03007777777', '2020-07-22', 'D001', 'SEC001', 'R003', 'EMP001', 7),
('EMP008', 'Maria Garcia', 'maria.garcia@honey.com', '03008888888', '2020-08-30', 'D002', 'SEC002', 'R003', 'EMP002', 8),
('EMP009', 'James Martinez', 'james.martinez@honey.com', '03009999999', '2020-09-14', 'D003', NULL, 'R003', 'EMP003', 9),
('EMP010', 'Patricia Lee', 'patricia.lee@honey.com', '03101111111', '2021-01-10', 'D001', 'SEC001', 'R004', 'EMP007', 10),
('EMP011', 'Thomas White', 'thomas.white@honey.com', '03102222222', '2021-02-15', 'D001', 'SEC001', 'R020', 'EMP007', 11),
('EMP012', 'Jennifer Clark', 'jennifer.clark@honey.com', '03103333333', '2021-03-20', 'D002', 'SEC002', 'R008', 'EMP008', 12),
('EMP013', 'Charles Rodriguez', 'charles.rodriguez@honey.com', '03104444444', '2021-04-25', 'D002', 'SEC003', 'R008', 'EMP008', 13),
('EMP014', 'Jessica Lewis', 'jessica.lewis@honey.com', '03105555555', '2021-05-30', 'D003', NULL, 'R011', 'EMP009', 14),
('EMP015', 'Daniel Walker', 'daniel.walker@honey.com', '03106666666', '2021-06-05', 'D003', NULL, 'R011', 'EMP009', 15),
('EMP016', 'Nancy Hall', 'nancy.hall@honey.com', '03107777777', '2021-07-12', 'D004', 'SEC005', 'R013', 'EMP004', 16),
('EMP017', 'Mark Young', 'mark.young@honey.com', '03108888888', '2021-08-18', 'D004', 'SEC006', 'R014', 'EMP004', 17),
('EMP018', 'Karen Allen', 'karen.allen@honey.com', '03109999999', '2021-09-22', 'D005', NULL, 'R009', 'EMP005', 18),
('EMP019', 'Steven King', 'steven.king@honey.com', '03201111111', '2021-10-28', 'D005', NULL, 'R020', 'EMP005', 19),
('EMP020', 'Betty Wright', 'betty.wright@honey.com', '03202222222', '2021-11-15', 'D006', NULL, 'R015', 'EMP006', 20),
('EMP021', 'George Scott', 'george.scott@honey.com', '03203333333', '2021-12-20', 'D006', NULL, 'R016', 'EMP006', 21),
('EMP022', 'Helen Adams', 'helen.adams@honey.com', '03204444444', '2022-01-25', 'D002', 'SEC004', 'R006', 'EMP002', 22),
('EMP023', 'Paul Nelson', 'paul.nelson@honey.com', '03205555555', '2022-02-28', 'D002', 'SEC004', 'R017', 'EMP008', 23),
('EMP024', 'Sandra Baker', 'sandra.baker@honey.com', '03206666666', '2022-03-15', 'D003', NULL, 'R018', 'EMP003', 24),
('EMP025', 'Larry Mitchell', 'larry.mitchell@honey.com', '03207777777', '2022-04-20', 'D001', 'SEC001', 'R007', 'EMP007', 25),
('EMP026', 'Donna Perez', 'donna.perez@honey.com', '03208888888', '2022-05-10', 'D001', NULL, 'R004', 'EMP001', 1),
('EMP027', 'Kevin Roberts', 'kevin.roberts@honey.com', '03209999999', '2022-06-18', 'D002', 'SEC002', 'R008', 'EMP008', 2),
('EMP028', 'Ruth Turner', 'ruth.turner@honey.com', '03301111111', '2022-07-22', 'D002', 'SEC003', 'R008', 'EMP008', 3),
('EMP029', 'Ronald Phillips', 'ronald.phillips@honey.com', '03302222222', '2022-08-30', 'D003', NULL, 'R011', 'EMP009', 4),
('EMP030', 'Sharon Campbell', 'sharon.campbell@honey.com', '03303333333', '2022-09-14', 'D004', 'SEC005', 'R013', 'EMP004', 5),
('EMP031', 'Timothy Parker', 'timothy.parker@honey.com', '03304444444', '2022-10-20', 'D004', 'SEC006', 'R014', 'EMP004', 6),
('EMP032', 'Deborah Evans', 'deborah.evans@honey.com', '03305555555', '2022-11-25', 'D005', NULL, 'R009', 'EMP005', 7),
('EMP033', 'Jeffrey Edwards', 'jeffrey.edwards@honey.com', '03306666666', '2022-12-15', 'D005', NULL, 'R020', 'EMP005', 8),
('EMP034', 'Cynthia Collins', 'cynthia.collins@honey.com', '03307777777', '2023-01-10', 'D006', NULL, 'R015', 'EMP006', 9),
('EMP035', 'Frank Stewart', 'frank.stewart@honey.com', '03308888888', '2023-02-18', 'D006', NULL, 'R016', 'EMP006', 10),
('EMP036', 'Brenda Sanchez', 'brenda.sanchez@honey.com', '03309999999', '2023-03-22', 'D001', NULL, 'R004', 'EMP001', 11),
('EMP037', 'Scott Morris', 'scott.morris@honey.com', '03401111111', '2023-04-28', 'D002', 'SEC001', 'R007', 'EMP002', 12),
('EMP038', 'Frances Rogers', 'frances.rogers@honey.com', '03402222222', '2023-05-15', 'D002', 'SEC002', 'R008', 'EMP008', 13),
('EMP039', 'Raymond Reed', 'raymond.reed@honey.com', '03403333333', '2023-06-20', 'D003', NULL, 'R011', 'EMP003', 14),
('EMP040', 'Judy Cook', 'judy.cook@honey.com', '03404444444', '2023-07-25', 'D004', 'SEC005', 'R013', 'EMP004', 15),
('EMP041', 'Dennis Morgan', 'dennis.morgan@honey.com', '03405555555', '2023-08-30', 'D004', 'SEC006', 'R014', 'EMP004', 16),
('EMP042', 'Janet Bell', 'janet.bell@honey.com', '03406666666', '2023-09-10', 'D005', NULL, 'R009', 'EMP005', 17),
('EMP043', 'Wayne Murphy', 'wayne.murphy@honey.com', '03407777777', '2023-10-15', 'D005', NULL, 'R020', 'EMP005', 18),
('EMP044', 'Katherine Bailey', 'katherine.bailey@honey.com', '03408888888', '2023-11-20', 'D006', NULL, 'R015', 'EMP006', 19),
('EMP045', 'Arthur Rivera', 'arthur.rivera@honey.com', '03409999999', '2023-12-05', 'D006', NULL, 'R016', 'EMP006', 20),
('EMP046', 'Mildred Cooper', 'mildred.cooper@honey.com', '03501111111', '2020-01-10', 'D001', 'SEC001', 'R004', 'EMP007', 21),
('EMP047', 'Lawrence Richardson', 'lawrence.richardson@honey.com', '03502222222', '2020-02-15', 'D002', 'SEC003', 'R008', 'EMP008', 22),
('EMP048', 'Rose Cox', 'rose.cox@honey.com', '03503333333', '2020-03-20', 'D003', NULL, 'R011', 'EMP009', 23),
('EMP049', 'Billy Howard', 'billy.howard@honey.com', '03504444444', '2020-04-25', 'D004', 'SEC005', 'R013', 'EMP004', 24),
('EMP050', 'Eugene Ward', 'eugene.ward@honey.com', '03505555555', '2020-05-30', 'D005', NULL, 'R009', 'EMP005', 25),
('EMP051', 'Ruby Torres', 'ruby.torres@honey.com', '03506666666', '2020-06-10', 'D006', NULL, 'R015', 'EMP006', 1),
('EMP052', 'Russell Peterson', 'russell.peterson@honey.com', '03507777777', '2020-07-15', 'D001', NULL, 'R004', 'EMP001', 2),
('EMP053', 'Lois Gray', 'lois.gray@honey.com', '03508888888', '2020-08-20', 'D002', 'SEC004', 'R006', 'EMP002', 3),
('EMP054', 'Alan Ramirez', 'alan.ramirez@honey.com', '03509999999', '2020-09-25', 'D002', 'SEC004', 'R017', 'EMP008', 4),
('EMP055', 'Phyllis James', 'phyllis.james@honey.com', '03601111111', '2020-10-30', 'D003', NULL, 'R018', 'EMP003', 5),
('EMP056', 'Jerry Watson', 'jerry.watson@honey.com', '03602222222', '2020-11-15', 'D004', 'SEC006', 'R014', 'EMP004', 6),
('EMP057', 'Andrea Brooks', 'andrea.brooks@honey.com', '03603333333', '2020-12-20', 'D005', NULL, 'R020', 'EMP005', 7),
('EMP058', 'Ralph Kelly', 'ralph.kelly@honey.com', '03604444444', '2021-01-25', 'D006', NULL, 'R016', 'EMP006', 8),
('EMP059', 'Teresa Sanders', 'teresa.sanders@honey.com', '03605555555', '2021-02-28', 'D001', 'SEC001', 'R007', 'EMP007', 9),
('EMP060', 'Jesse Price', 'jesse.price@honey.com', '03606666666', '2021-03-15', 'D002', 'SEC002', 'R008', 'EMP008', 10),
('EMP061', 'Diana Bennett', 'diana.bennett@honey.com', '03607777777', '2021-04-20', 'D003', NULL, 'R011', 'EMP009', 11),
('EMP062', 'Bruce Wood', 'bruce.wood@honey.com', '03608888888', '2021-05-25', 'D004', 'SEC005', 'R013', 'EMP004', 12),
('EMP063', 'Marilyn Barnes', 'marilyn.barnes@honey.com', '03609999999', '2021-06-30', 'D005', NULL, 'R009', 'EMP005', 13),
('EMP064', 'Harry Ross', 'harry.ross@honey.com', '03701111111', '2021-07-10', 'D006', NULL, 'R015', 'EMP006', 14),
('EMP065', 'Julie Henderson', 'julie.henderson@honey.com', '03702222222', '2021-08-15', 'D001', NULL, 'R004', 'EMP001', 15),
('EMP066', 'Johnny Coleman', 'johnny.coleman@honey.com', '03703333333', '2021-09-20', 'D002', 'SEC003', 'R008', 'EMP008', 16),
('EMP067', 'Anna Jenkins', 'anna.jenkins@honey.com', '03704444444', '2021-10-25', 'D003', NULL, 'R011', 'EMP009', 17),
('EMP068', 'Dylan Perry', 'dylan.perry@honey.com', '03705555555', '2021-11-30', 'D004', 'SEC006', 'R014', 'EMP004', 18),
('EMP069', 'Evelyn Powell', 'evelyn.powell@honey.com', '03706666666', '2021-12-15', 'D005', NULL, 'R020', 'EMP005', 19),
('EMP070', 'Zachary Long', 'zachary.long@honey.com', '03707777777', '2022-01-20', 'D006', NULL, 'R016', 'EMP006', 20);

-- =========================
-- UPDATE DEPARTMENT MANAGERS
-- =========================
UPDATE department SET manager_id = 'EMP001' WHERE department_id = 'D001';
UPDATE department SET manager_id = 'EMP002' WHERE department_id = 'D002';
UPDATE department SET manager_id = 'EMP003' WHERE department_id = 'D003';
UPDATE department SET manager_id = 'EMP004' WHERE department_id = 'D004';
UPDATE department SET manager_id = 'EMP005' WHERE department_id = 'D005';
UPDATE department SET manager_id = 'EMP006' WHERE department_id = 'D006';

-- =========================
-- 70 RECORDS FOR CANDIDATE TABLE
-- =========================
INSERT INTO candidate (candidate_id, candidate_name, candidate_email, candidate_phone, qualification, cv_link, experience) VALUES
('CAN001', 'Alice Johnson', 'alice.j@gmail.com', '03111111111', 'BS Agriculture', 'cv_alice.pdf', 2),
('CAN002', 'Bob Williams', 'bob.w@gmail.com', '03111111112', 'MS Food Technology', 'cv_bob.pdf', 3),
('CAN003', 'Carol Brown', 'carol.b@gmail.com', '03111111113', 'MBA Marketing', 'cv_carol.pdf', 4),
('CAN004', 'David Jones', 'david.j@gmail.com', '03111111114', 'BCom', 'cv_david.pdf', 1),
('CAN005', 'Emma Miller', 'emma.m@gmail.com', '03111111115', 'BS Biology', 'cv_emma.pdf', 2),
('CAN006', 'Frank Davis', 'frank.d@gmail.com', '03111111116', 'BBA', 'cv_frank.pdf', 0),
('CAN007', 'Grace Garcia', 'grace.g@gmail.com', '03111111117', 'MS Chemistry', 'cv_grace.pdf', 5),
('CAN008', 'Henry Rodriguez', 'henry.r@gmail.com', '03111111118', 'BS Computer Science', 'cv_henry.pdf', 3),
('CAN009', 'Irene Martinez', 'irene.m@gmail.com', '03111111119', 'MBA HR', 'cv_irene.pdf', 4),
('CAN010', 'Jack Wilson', 'jack.w@gmail.com', '03111111120', 'BSc Agriculture', 'cv_jack.pdf', 1),
('CAN011', 'Kelly Anderson', 'kelly.a@gmail.com', '03111111121', 'MS Food Science', 'cv_kelly.pdf', 2),
('CAN012', 'Leo Thomas', 'leo.t@gmail.com', '03111111122', 'BCom', 'cv_leo.pdf', 0),
('CAN013', 'Mia Taylor', 'mia.t@gmail.com', '03111111123', 'BS Microbiology', 'cv_mia.pdf', 3),
('CAN014', 'Noah Moore', 'noah.m@gmail.com', '03111111124', 'MBA Finance', 'cv_noah.pdf', 5),
('CAN015', 'Olivia Jackson', 'olivia.j@gmail.com', '03111111125', 'BBA', 'cv_olivia.pdf', 1),
('CAN016', 'Paul Martin', 'paul.m@gmail.com', '03111111126', 'BS Chemistry', 'cv_paul.pdf', 2),
('CAN017', 'Quinn Lee', 'quinn.l@gmail.com', '03111111127', 'MS Biology', 'cv_quinn.pdf', 4),
('CAN018', 'Rachel White', 'rachel.w@gmail.com', '03111111128', 'BSc Agriculture', 'cv_rachel.pdf', 2),
('CAN019', 'Steve Harris', 'steve.h@gmail.com', '03111111129', 'MBA Marketing', 'cv_steve.pdf', 3),
('CAN020', 'Tina Clark', 'tina.c@gmail.com', '03111111130', 'BS Food Technology', 'cv_tina.pdf', 1),
('CAN021', 'Umar Lewis', 'umar.l@gmail.com', '03111111131', 'BCom', 'cv_umar.pdf', 0),
('CAN022', 'Vanessa Robinson', 'vanessa.r@gmail.com', '03111111132', 'MS HR', 'cv_vanessa.pdf', 4),
('CAN023', 'Walter Walker', 'walter.w@gmail.com', '03111111133', 'BS Computer Science', 'cv_walter.pdf', 2),
('CAN024', 'Xena Young', 'xena.y@gmail.com', '03111111134', 'BBA', 'cv_xena.pdf', 1),
('CAN025', 'Yusuf Allen', 'yusuf.a@gmail.com', '03111111135', 'MS Agriculture', 'cv_yusuf.pdf', 3),
('CAN026', 'Zara King', 'zara.k@gmail.com', '03111111136', 'BS Chemistry', 'cv_zara.pdf', 2),
('CAN027', 'Aaron Scott', 'aaron.s@gmail.com', '03111111137', 'MBA Finance', 'cv_aaron.pdf', 5),
('CAN028', 'Bella Green', 'bella.g@gmail.com', '03111111138', 'BSc Biology', 'cv_bella.pdf', 1),
('CAN029', 'Caleb Baker', 'caleb.b@gmail.com', '03111111139', 'MS Food Technology', 'cv_caleb.pdf', 3),
('CAN030', 'Diana Adams', 'diana.a@gmail.com', '03111111140', 'BBA', 'cv_diana.pdf', 0),
('CAN031', 'Evan Nelson', 'evan.n@gmail.com', '03111111141', 'BS Agriculture', 'cv_evan.pdf', 2),
('CAN032', 'Fiona Carter', 'fiona.c@gmail.com', '03111111142', 'MBA Marketing', 'cv_fiona.pdf', 4),
('CAN033', 'Gabriel Mitchell', 'gabriel.m@gmail.com', '03111111143', 'MS Chemistry', 'cv_gabriel.pdf', 3),
('CAN034', 'Hannah Perez', 'hannah.p@gmail.com', '03111111144', 'BCom', 'cv_hannah.pdf', 1),
('CAN035', 'Ian Roberts', 'ian.r@gmail.com', '03111111145', 'BS Food Science', 'cv_ian.pdf', 2),
('CAN036', 'Julia Turner', 'julia.t@gmail.com', '03111111146', 'MBA HR', 'cv_julia.pdf', 5),
('CAN037', 'Kevin Phillips', 'kevin.p@gmail.com', '03111111147', 'BSc Agriculture', 'cv_kevin.pdf', 2),
('CAN038', 'Laura Campbell', 'laura.c@gmail.com', '03111111148', 'MS Biology', 'cv_laura.pdf', 3),
('CAN039', 'Mike Parker', 'mike.p@gmail.com', '03111111149', 'BBA', 'cv_mike.pdf', 0),
('CAN040', 'Nina Evans', 'nina.e@gmail.com', '03111111150', 'BS Chemistry', 'cv_nina.pdf', 1),
('CAN041', 'Oscar Edwards', 'oscar.e@gmail.com', '03111111151', 'MBA Finance', 'cv_oscar.pdf', 4),
('CAN042', 'Paula Collins', 'paula.c@gmail.com', '03111111152', 'MS Food Technology', 'cv_paula.pdf', 3),
('CAN043', 'Quincy Stewart', 'quincy.s@gmail.com', '03111111153', 'BCom', 'cv_quincy.pdf', 2),
('CAN044', 'Rose Sanchez', 'rose.s@gmail.com', '03111111154', 'BS Agriculture', 'cv_rose.pdf', 1),
('CAN045', 'Sam Morris', 'sam.m@gmail.com', '03111111155', 'MBA Marketing', 'cv_sam.pdf', 5),
('CAN046', 'Tracy Rogers', 'tracy.r@gmail.com', '03111111156', 'MS HR', 'cv_tracy.pdf', 3),
('CAN047', 'Uriah Reed', 'uriah.r@gmail.com', '03111111157', 'BSc Biology', 'cv_uriah.pdf', 2),
('CAN048', 'Vera Cook', 'vera.c@gmail.com', '03111111158', 'BS Computer Science', 'cv_vera.pdf', 4),
('CAN049', 'Will Morgan', 'will.m@gmail.com', '03111111159', 'BBA', 'cv_will.pdf', 0),
('CAN050', 'Xavier Bell', 'xavier.b@gmail.com', '03111111160', 'MS Chemistry', 'cv_xavier.pdf', 2),
('CAN051', 'Yara Murphy', 'yara.m@gmail.com', '03111111161', 'MBA Finance', 'cv_yara.pdf', 3),
('CAN052', 'Zane Bailey', 'zane.b@gmail.com', '03111111162', 'BS Food Technology', 'cv_zane.pdf', 1),
('CAN053', 'Amelia Rivera', 'amelia.r@gmail.com', '03111111163', 'BSc Agriculture', 'cv_amelia.pdf', 4),
('CAN054', 'Blake Cooper', 'blake.c@gmail.com', '03111111164', 'MS Biology', 'cv_blake.pdf', 2),
('CAN055', 'Chloe Richardson', 'chloe.r@gmail.com', '03111111165', 'MBA Marketing', 'cv_chloe.pdf', 3),
('CAN056', 'Derek Cox', 'derek.c@gmail.com', '03111111166', 'BCom', 'cv_derek.pdf', 1),
('CAN057', 'Ella Howard', 'ella.h@gmail.com', '03111111167', 'BS Chemistry', 'cv_ella.pdf', 2),
('CAN058', 'Finn Ward', 'finn.w@gmail.com', '03111111168', 'MS HR', 'cv_finn.pdf', 4),
('CAN059', 'Gina Torres', 'gina.t@gmail.com', '03111111169', 'BBA', 'cv_gina.pdf', 0),
('CAN060', 'Hugh Peterson', 'hugh.p@gmail.com', '03111111170', 'BS Agriculture', 'cv_hugh.pdf', 3),
('CAN061', 'Ivy Gray', 'ivy.g@gmail.com', '03111111171', 'MBA Finance', 'cv_ivy.pdf', 5),
('CAN062', 'Jake Ramirez', 'jake.r@gmail.com', '03111111172', 'MS Food Technology', 'cv_jake.pdf', 2),
('CAN063', 'Kara James', 'kara.j@gmail.com', '03111111173', 'BSc Biology', 'cv_kara.pdf', 1),
('CAN064', 'Liam Watson', 'liam.w@gmail.com', '03111111174', 'BCom', 'cv_liam.pdf', 0),
('CAN065', 'Mona Brooks', 'mona.b@gmail.com', '03111111175', 'BS Chemistry', 'cv_mona.pdf', 3),
('CAN066', 'Nathan Kelly', 'nathan.k@gmail.com', '03111111176', 'MBA Marketing', 'cv_nathan.pdf', 4),
('CAN067', 'Opal Sanders', 'opal.s@gmail.com', '03111111177', 'MS Agriculture', 'cv_opal.pdf', 2),
('CAN068', 'Peter Price', 'peter.p@gmail.com', '03111111178', 'BBA', 'cv_peter.pdf', 1),
('CAN069', 'Queen Bennett', 'queen.b@gmail.com', '03111111179', 'BS Food Technology', 'cv_queen.pdf', 3),
('CAN070', 'Ryan Wood', 'ryan.w@gmail.com', '03111111180', 'MBA HR', 'cv_ryan.pdf', 4);

-- =========================
-- 70 RECORDS FOR HONEY_BATCH TABLE
-- =========================
INSERT INTO honey_batch (batch_id, quantity, received_date, bucket_id) VALUES
('B001', 150.50, '2024-01-15', 1), ('B002', 200.75, '2024-01-20', 2), ('B003', 175.25, '2024-01-25', 3),
('B004', 120.00, '2024-02-01', 4), ('B005', 250.50, '2024-02-05', 5), ('B006', 180.30, '2024-02-10', 6),
('B007', 210.80, '2024-02-15', 7), ('B008', 195.40, '2024-02-20', 8), ('B009', 165.90, '2024-02-25', 9),
('B010', 225.60, '2024-03-01', 10), ('B011', 140.20, '2024-03-05', 11), ('B012', 190.70, '2024-03-10', 12),
('B013', 230.40, '2024-03-15', 13), ('B014', 185.50, '2024-03-20', 14), ('B015', 205.80, '2024-03-25', 15),
('B016', 170.30, '2024-04-01', 16), ('B017', 245.90, '2024-04-05', 17), ('B018', 160.60, '2024-04-10', 18),
('B019', 215.40, '2024-04-15', 19), ('B020', 195.20, '2024-04-20', 20), ('B021', 235.70, '2024-04-25', 21),
('B022', 155.80, '2024-05-01', 22), ('B023', 225.50, '2024-05-05', 23), ('B024', 185.90, '2024-05-10', 24),
('B025', 205.30, '2024-05-15', 25), ('B026', 175.40, '2024-05-20', 1), ('B027', 240.80, '2024-05-25', 2),
('B028', 190.20, '2024-06-01', 3), ('B029', 220.60, '2024-06-05', 4), ('B030', 165.70, '2024-06-10', 5),
('B031', 210.90, '2024-06-15', 6), ('B032', 195.50, '2024-06-20', 7), ('B033', 230.40, '2024-06-25', 8),
('B034', 180.80, '2024-07-01', 9), ('B035', 215.30, '2024-07-05', 10), ('B036', 170.60, '2024-07-10', 11),
('B037', 245.20, '2024-07-15', 12), ('B038', 200.90, '2024-07-20', 13), ('B039', 185.40, '2024-07-25', 14),
('B040', 225.70, '2024-08-01', 15), ('B041', 160.50, '2024-08-05', 16), ('B042', 235.80, '2024-08-10', 17),
('B043', 195.30, '2024-08-15', 18), ('B044', 210.60, '2024-08-20', 19), ('B045', 175.90, '2024-08-25', 20),
('B046', 250.40, '2024-09-01', 21), ('B047', 190.70, '2024-09-05', 22), ('B048', 220.50, '2024-09-10', 23),
('B049', 185.80, '2024-09-15', 24), ('B050', 205.20, '2024-09-20', 25), ('B051', 240.60, '2024-09-25', 1),
('B052', 170.40, '2024-10-01', 2), ('B053', 215.90, '2024-10-05', 3), ('B054', 195.70, '2024-10-10', 4),
('B055', 230.50, '2024-10-15', 5), ('B056', 180.30, '2024-10-20', 6), ('B057', 225.80, '2024-10-25', 7),
('B058', 160.90, '2024-11-01', 8), ('B059', 245.60, '2024-11-05', 9), ('B060', 200.40, '2024-11-10', 10),
('B061', 190.80, '2024-11-15', 11), ('B062', 235.20, '2024-11-20', 12), ('B063', 175.50, '2024-11-25', 13),
('B064', 210.70, '2024-12-01', 14), ('B065', 185.60, '2024-12-05', 15), ('B066', 220.90, '2024-12-10', 16),
('B067', 195.40, '2024-12-15', 17), ('B068', 230.80, '2024-12-20', 18), ('B069', 170.20, '2024-12-25', 19),
('B070', 250.50, '2024-12-30', 20);

-- =========================
-- 70 RECORDS FOR PACKAGE TABLE
-- =========================
INSERT INTO package (package_id, size, type, price, distributor_id) VALUES
('PKG001', '250g', 'Glass Jar', 5.99, 1), ('PKG002', '500g', 'Glass Jar', 9.99, 2),
('PKG003', '1kg', 'Glass Jar', 15.99, 3), ('PKG004', '250g', 'Plastic Bottle', 4.99, 4),
('PKG005', '500g', 'Plastic Bottle', 8.99, 5), ('PKG006', '1kg', 'Plastic Bottle', 14.99, 6),
('PKG007', '250g', 'Squeeze Bottle', 5.49, 7), ('PKG008', '500g', 'Squeeze Bottle', 9.49, 8),
('PKG009', '1kg', 'Squeeze Bottle', 15.49, 9), ('PKG010', '2kg', 'Plastic Jar', 25.99, 10),
('PKG011', '5kg', 'Plastic Bucket', 45.99, 11), ('PKG012', '10kg', 'Plastic Bucket', 85.99, 12),
('PKG013', '25kg', 'Industrial Drum', 199.99, 13), ('PKG014', '50g', 'Pouch', 1.99, 14),
('PKG015', '100g', 'Pouch', 2.99, 15), ('PKG016', '250g', 'Pouch', 4.99, 16),
('PKG017', '500g', 'Pouch', 7.99, 17), ('PKG018', '1kg', 'Pouch', 12.99, 18),
('PKG019', '250g', 'Tub', 5.79, 19), ('PKG020', '500g', 'Tub', 9.79, 20),
('PKG021', '1kg', 'Tub', 15.79, 21), ('PKG022', '250g', 'Ceramic Jar', 8.99, 22),
('PKG023', '500g', 'Ceramic Jar', 14.99, 23), ('PKG024', '1kg', 'Ceramic Jar', 24.99, 24),
('PKG025', '250g', 'Wooden Box', 12.99, 25), ('PKG026', '500g', 'Wooden Box', 19.99, 1),
('PKG027', '1kg', 'Wooden Box', 29.99, 2), ('PKG028', '3kg', 'Plastic Jar', 35.99, 3),
('PKG029', '4kg', 'Plastic Jar', 45.99, 4), ('PKG030', '15kg', 'Plastic Bucket', 125.99, 5),
('PKG031', '20kg', 'Plastic Bucket', 165.99, 6), ('PKG032', '30kg', 'Industrial Drum', 229.99, 7),
('PKG033', '40kg', 'Industrial Drum', 299.99, 8), ('PKG034', '50kg', 'Industrial Drum', 399.99, 9),
('PKG035', '75g', 'Pouch', 1.49, 10), ('PKG036', '150g', 'Pouch', 2.49, 11),
('PKG037', '200g', 'Pouch', 3.49, 12), ('PKG038', '300g', 'Pouch', 5.99, 13),
('PKG039', '750g', 'Pouch', 10.99, 14), ('PKG040', '1.5kg', 'Pouch', 16.99, 15),
('PKG041', '2.5kg', 'Plastic Jar', 29.99, 16), ('PKG042', '3.5kg', 'Plastic Jar', 39.99, 17),
('PKG043', '6kg', 'Plastic Bucket', 55.99, 18), ('PKG044', '8kg', 'Plastic Bucket', 75.99, 19),
('PKG045', '12kg', 'Plastic Bucket', 105.99, 20), ('PKG046', '18kg', 'Plastic Bucket', 145.99, 21),
('PKG047', '22kg', 'Industrial Drum', 189.99, 22), ('PKG048', '28kg', 'Industrial Drum', 219.99, 23),
('PKG049', '35kg', 'Industrial Drum', 279.99, 24), ('PKG050', '45kg', 'Industrial Drum', 349.99, 25),
('PKG051', '60kg', 'Industrial Drum', 499.99, 1), ('PKG052', '80kg', 'Industrial Drum', 649.99, 2),
('PKG053', '100kg', 'Industrial Drum', 799.99, 3), ('PKG054', '125g', 'Glass Jar', 3.99, 4),
('PKG055', '375g', 'Glass Jar', 7.99, 5), ('PKG056', '750g', 'Glass Jar', 12.99, 6),
('PKG057', '1.25kg', 'Glass Jar', 18.99, 7), ('PKG058', '1.75kg', 'Glass Jar', 22.99, 8),
('PKG059', '2.25kg', 'Plastic Bottle', 28.99, 9), ('PKG060', '2.75kg', 'Plastic Bottle', 32.99, 10),
('PKG061', '3.25kg', 'Plastic Bottle', 37.99, 11), ('PKG062', '4.5kg', 'Plastic Jar', 49.99, 12),
('PKG063', '5.5kg', 'Plastic Jar', 59.99, 13), ('PKG064', '7kg', 'Plastic Bucket', 69.99, 14),
('PKG065', '9kg', 'Plastic Bucket', 89.99, 15), ('PKG066', '11kg', 'Plastic Bucket', 99.99, 16),
('PKG067', '14kg', 'Plastic Bucket', 129.99, 17), ('PKG068', '16kg', 'Plastic Bucket', 139.99, 18),
('PKG069', '55kg', 'Industrial Drum', 449.99, 19), ('PKG070', '75kg', 'Industrial Drum', 599.99, 20);

-- =========================
-- 70 RECORDS FOR TREE TABLE
-- =========================
INSERT INTO Tree (tree_id, farm_id, tree_water_consumption, tree_height, tree_location, tree_plantation_date) VALUES
(1, 1, 50.5, 12.5, 'North Section A', '2018-01-10'), (2, 1, 48.2, 11.8, 'North Section B', '2018-01-15'),
(3, 1, 52.1, 13.2, 'North Section C', '2018-01-20'), (4, 2, 45.8, 10.5, 'East Section A', '2018-02-05'),
(5, 2, 47.3, 11.2, 'East Section B', '2018-02-10'), (6, 2, 49.6, 12.0, 'East Section C', '2018-02-15'),
(7, 3, 51.4, 12.8, 'West Section A', '2018-03-01'), (8, 3, 53.2, 13.5, 'West Section B', '2018-03-05'),
(9, 3, 50.9, 12.3, 'West Section C', '2018-03-10'), (10, 4, 46.5, 10.2, 'South Section A', '2018-04-12'),
(11, 4, 48.1, 11.0, 'South Section B', '2018-04-15'), (12, 4, 49.8, 11.7, 'South Section C', '2018-04-18'),
(13, 5, 52.5, 13.0, 'Central Section A', '2018-05-20'), (14, 5, 54.1, 14.2, 'Central Section B', '2018-05-25'),
(15, 5, 51.2, 12.6, 'Central Section C', '2018-05-30'), (16, 6, 47.9, 10.8, 'Northwest Section', '2018-06-10'),
(17, 6, 49.4, 11.5, 'Northeast Section', '2018-06-15'), (18, 6, 50.7, 12.1, 'Southwest Section', '2018-06-20'),
(19, 7, 53.6, 13.8, 'Southeast Section', '2018-07-05'), (20, 7, 55.2, 14.5, 'Hilltop Area', '2018-07-10'),
(21, 7, 52.8, 13.3, 'Valley Area', '2018-07-15'), (22, 8, 46.8, 10.4, 'Riverside A', '2018-08-20'),
(23, 8, 48.5, 11.1, 'Riverside B', '2018-08-25'), (24, 8, 50.1, 11.9, 'Riverside C', '2018-08-30'),
(25, 9, 51.7, 12.4, 'Meadow Area A', '2018-09-10'), (26, 9, 53.4, 13.6, 'Meadow Area B', '2018-09-15'),
(27, 9, 49.2, 11.4, 'Meadow Area C', '2018-09-20'), (28, 10, 47.6, 10.6, 'Forest Edge A', '2018-10-05'),
(29, 10, 49.1, 11.3, 'Forest Edge B', '2018-10-10'), (30, 10, 50.5, 12.0, 'Forest Edge C', '2018-10-15'),
(31, 11, 52.3, 12.9, 'Open Field A', '2019-01-08'), (32, 11, 54.0, 13.9, 'Open Field B', '2019-01-12'),
(33, 11, 51.6, 12.7, 'Open Field C', '2019-01-16'), (34, 12, 48.3, 10.9, 'Woodland A', '2019-02-20'),
(35, 12, 49.9, 11.6, 'Woodland B', '2019-02-24'), (36, 12, 51.0, 12.2, 'Woodland C', '2019-02-28'),
(37, 13, 53.8, 13.7, 'Highland A', '2019-03-15'), (38, 13, 55.5, 14.8, 'Highland B', '2019-03-18'),
(39, 13, 52.9, 13.4, 'Highland C', '2019-03-22'), (40, 14, 47.2, 10.7, 'Lowland A', '2019-04-10'),
(41, 14, 48.8, 11.4, 'Lowland B', '2019-04-14'), (42, 14, 50.3, 12.1, 'Lowland C', '2019-04-18'),
(43, 15, 51.9, 12.5, 'Plateau A', '2019-05-05'), (44, 15, 53.7, 13.8, 'Plateau B', '2019-05-09'),
(45, 15, 50.8, 12.3, 'Plateau C', '2019-05-13'), (46, 16, 46.9, 10.3, 'Delta A', '2019-06-25'),
(47, 16, 48.6, 11.2, 'Delta B', '2019-06-28'), (48, 16, 50.2, 12.0, 'Delta C', '2019-07-02'),
(49, 17, 52.4, 13.1, 'Basin A', '2019-07-20'), (50, 17, 54.2, 14.0, 'Basin B', '2019-07-24'),
(51, 17, 51.5, 12.8, 'Basin C', '2019-07-28'), (52, 18, 47.8, 10.5, 'Terrace A', '2019-08-15'),
(53, 18, 49.3, 11.3, 'Terrace B', '2019-08-19'), (54, 18, 50.6, 12.1, 'Terrace C', '2019-08-23'),
(55, 19, 52.7, 13.2, 'Slope A', '2019-09-10'), (56, 19, 54.4, 14.1, 'Slope B', '2019-09-14'),
(57, 19, 51.8, 12.9, 'Slope C', '2019-09-18'), (58, 20, 48.0, 10.9, 'Plain A', '2019-10-05'),
(59, 20, 49.5, 11.7, 'Plain B', '2019-10-09'), (60, 20, 50.9, 12.4, 'Plain C', '2019-10-13'),
(61, 21, 53.1, 13.5, 'Ridge A', '2020-01-20'), (62, 21, 54.8, 14.3, 'Ridge B', '2020-01-24'),
(63, 21, 52.2, 13.0, 'Ridge C', '2020-01-28'), (64, 22, 47.5, 10.8, 'Canyon A', '2020-02-15'),
(65, 22, 49.0, 11.5, 'Canyon B', '2020-02-19'), (66, 22, 50.4, 12.2, 'Canyon C', '2020-02-23'),
(67, 23, 52.6, 13.4, 'Summit A', '2020-03-10'), (68, 23, 54.3, 14.2, 'Summit B', '2020-03-14'),
(69, 23, 51.9, 12.9, 'Summit C', '2020-03-18'), (70, 24, 48.4, 11.1, 'Coastal A', '2020-04-05');

-- =========================
-- 70 RECORDS FOR PLANT TABLE
-- =========================
INSERT INTO Plant (plant_id, farm_id, plant_type, plant_plantation_date, plant_location, plant_water_consumption) VALUES
(1, 1, 'Clover', '2019-01-10', 'Field A1', 30.5), (2, 1, 'Alfalfa', '2019-01-15', 'Field A2', 35.2),
(3, 1, 'Sunflower', '2019-01-20', 'Field A3', 28.8), (4, 2, 'Lavender', '2019-02-05', 'Field B1', 25.5),
(5, 2, 'Rosemary', '2019-02-10', 'Field B2', 22.3), (6, 2, 'Thyme', '2019-02-15', 'Field B3', 20.1),
(7, 3, 'Buckwheat', '2019-03-01', 'Field C1', 32.7), (8, 3, 'Mustard', '2019-03-05', 'Field C2', 29.4),
(9, 3, 'Rapeseed', '2019-03-10', 'Field C3', 31.2), (10, 4, 'Acacia', '2019-04-12', 'Field D1', 40.5),
(11, 4, 'Eucalyptus', '2019-04-15', 'Field D2', 45.8), (12, 4, 'Citrus', '2019-04-18', 'Field D3', 38.3),
(13, 5, 'Berry Bushes', '2019-05-20', 'Field E1', 27.5), (14, 5, 'Fruit Trees', '2019-05-25', 'Field E2', 55.0),
(15, 5, 'Wildflowers', '2019-05-30', 'Field E3', 23.4), (16, 6, 'Mint', '2019-06-10', 'Field F1', 18.9),
(17, 6, 'Basil', '2019-06-15', 'Field F2', 19.5), (18, 6, 'Oregano', '2019-06-20', 'Field F3', 17.8),
(19, 7, 'Sage', '2019-07-05', 'Field G1', 21.3), (20, 7, 'Manuka', '2019-07-10', 'Field G2', 48.5),
(21, 7, 'Jarrah', '2019-07-15', 'Field G3', 52.1), (22, 8, 'Leatherwood', '2019-08-20', 'Field H1', 44.2),
(23, 8, 'Tupelo', '2019-08-25', 'Field H2', 42.7), (24, 8, 'Sourwood', '2019-08-30', 'Field H3', 41.3),
(25, 9, 'Orange Blossom', '2019-09-10', 'Field I1', 36.5), (26, 9, 'Linden', '2019-09-15', 'Field I2', 39.8),
(27, 9, 'Chestnut', '2019-09-20', 'Field I3', 43.2), (28, 10, 'Heather', '2019-10-05', 'Field J1', 26.7),
(29, 10, 'Fireweed', '2019-10-10', 'Field J2', 24.5), (30, 10, 'Goldenrod', '2019-10-15', 'Field J3', 22.9),
(31, 11, 'Dandelion', '2020-01-08', 'Field K1', 16.5), (32, 11, 'Blackberry', '2020-01-12', 'Field K2', 29.8),
(33, 11, 'Raspberry', '2020-01-16', 'Field K3', 28.4), (34, 12, 'Blueberry', '2020-02-20', 'Field L1', 31.5),
(35, 12, 'Cranberry', '2020-02-24', 'Field L2', 33.2), (36, 12, 'Strawberry', '2020-02-28', 'Field L3', 27.9),
(37, 13, 'Pumpkin', '2020-03-15', 'Field M1', 34.8), (38, 13, 'Cucumber', '2020-03-18', 'Field M2', 37.5),
(39, 13, 'Melon', '2020-03-22', 'Field M3', 40.2), (40, 14, 'Cotton', '2020-04-10', 'Field N1', 35.9),
(41, 14, 'Soybean', '2020-04-14', 'Field N2', 32.4), (42, 14, 'Peanut', '2020-04-18', 'Field N3', 30.8),
(43, 15, 'Cornflower', '2020-05-05', 'Field O1', 25.3), (44, 15, 'Marigold', '2020-05-09', 'Field O2', 23.7),
(45, 15, 'Zinnia', '2020-05-13', 'Field O3', 21.9), (46, 16, 'Cosmos', '2020-06-25', 'Field P1', 20.5),
(47, 16, 'Daisy', '2020-06-28', 'Field P2', 19.2), (48, 16, 'Aster', '2020-07-02', 'Field P3', 18.6),
(49, 17, 'Verbena', '2020-07-20', 'Field Q1', 22.4), (50, 17, 'Phacelia', '2020-07-24', 'Field Q2', 24.1),
(51, 17, 'Borage', '2020-07-28', 'Field Q3', 26.8), (52, 18, 'Fennel', '2020-08-15', 'Field R1', 28.9),
(53, 18, 'Coriander', '2020-08-19', 'Field R2', 27.5), (54, 18, 'Parsley', '2020-08-23', 'Field R3', 25.7),
(55, 19, 'Dill', '2020-09-10', 'Field S1', 24.3), (56, 19, 'Chamomile', '2020-09-14', 'Field S2', 22.8),
(57, 19, 'Echinacea', '2020-09-18', 'Field S3', 26.5), (58, 20, 'Milkweed', '2020-10-05', 'Field T1', 21.7),
(59, 20, 'Goldenrod', '2020-10-09', 'Field T2', 23.2), (60, 20, 'Ironweed', '2020-10-13', 'Field T3', 24.9),
(61, 21, 'Joe Pye', '2021-01-20', 'Field U1', 27.3), (62, 21, 'Bergamot', '2021-01-24', 'Field U2', 25.6),
(63, 21, 'Hyssop', '2021-01-28', 'Field U3', 23.9), (64, 22, 'Lovage', '2021-02-15', 'Field V1', 29.4),
(65, 22, 'Angelica', '2021-02-19', 'Field V2', 31.2), (66, 22, 'Meadowsweet', '2021-02-23', 'Field V3', 28.7),
(67, 23, 'Willowherb', '2021-03-10', 'Field W1', 26.3), (68, 23, 'Foxglove', '2021-03-14', 'Field W2', 24.8),
(69, 23, 'Larkspur', '2021-03-18', 'Field W3', 23.1), (70, 24, 'Delphinium', '2021-04-05', 'Field X1', 22.5);

-- =========================
-- 70 RECORDS FOR WATER_RESOURCE TABLE
-- =========================
INSERT INTO Water_Resource (water_resource_id, farm_id, water_resource_type, water_resource_area, water_resource_capacity, water_resource_current_water_level, water_resource_location) VALUES
(1, 1, 'Well', 5.5, 50000, 35000, 'North Corner'), (2, 1, 'Pond', 25.0, 100000, 75000, 'East Side'),
(3, 1, 'River', 50.0, 500000, 400000, 'West Boundary'), (4, 2, 'Borewell', 2.0, 30000, 25000, 'Center'),
(5, 2, 'Tank', 15.0, 60000, 45000, 'South Side'), (6, 2, 'Canal', 30.0, 200000, 150000, 'North Side'),
(7, 3, 'Spring', 8.0, 25000, 20000, 'Hill Base'), (8, 3, 'Reservoir', 40.0, 300000, 250000, 'Valley'),
(9, 3, 'Stream', 20.0, 80000, 60000, 'Forest Edge'), (10, 4, 'Well', 6.0, 45000, 35000, 'Field A'),
(11, 4, 'Pond', 30.0, 120000, 90000, 'Field B'), (12, 4, 'Borewell', 3.0, 35000, 28000, 'Field C'),
(13, 5, 'River', 60.0, 600000, 500000, 'East Side'), (14, 5, 'Canal', 35.0, 250000, 200000, 'West Side'),
(15, 5, 'Tank', 20.0, 75000, 60000, 'Central'), (16, 6, 'Spring', 10.0, 30000, 24000, 'North Area'),
(17, 6, 'Well', 7.0, 55000, 44000, 'South Area'), (18, 6, 'Pond', 28.0, 110000, 88000, 'East Area'),
(19, 7, 'Reservoir', 45.0, 350000, 280000, 'West Area'), (20, 7, 'Borewell', 4.0, 40000, 32000, 'Hilltop'),
(21, 7, 'Stream', 22.0, 90000, 72000, 'Valley'), (22, 8, 'Well', 5.0, 48000, 38000, 'North Field'),
(23, 8, 'Canal', 32.0, 220000, 176000, 'South Field'), (24, 8, 'Pond', 26.0, 95000, 76000, 'East Field'),
(25, 9, 'River', 55.0, 550000, 440000, 'West Field'), (26, 9, 'Tank', 18.0, 70000, 56000, 'Center'),
(27, 9, 'Spring', 9.0, 28000, 22400, 'Corner'), (28, 10, 'Borewell', 3.5, 38000, 30400, 'Zone A'),
(29, 10, 'Well', 6.5, 52000, 41600, 'Zone B'), (30, 10, 'Pond', 32.0, 130000, 104000, 'Zone C'),
(31, 11, 'Reservoir', 48.0, 380000, 304000, 'Section 1'), (32, 11, 'Stream', 24.0, 100000, 80000, 'Section 2'),
(33, 11, 'Canal', 38.0, 280000, 224000, 'Section 3'), (34, 12, 'Spring', 11.0, 32000, 25600, 'Plot A'),
(35, 12, 'Well', 7.5, 58000, 46400, 'Plot B'), (36, 12, 'Pond', 35.0, 140000, 112000, 'Plot C'),
(37, 13, 'River', 65.0, 650000, 520000, 'Area 1'), (38, 13, 'Borewell', 4.5, 42000, 33600, 'Area 2'),
(39, 13, 'Tank', 22.0, 85000, 68000, 'Area 3'), (40, 14, 'Well', 8.0, 60000, 48000, 'Block A'),
(41, 14, 'Canal', 42.0, 320000, 256000, 'Block B'), (42, 14, 'Pond', 38.0, 150000, 120000, 'Block C'),
(43, 15, 'Stream', 26.0, 110000, 88000, 'Sector 1'), (44, 15, 'Reservoir', 52.0, 420000, 336000, 'Sector 2'),
(45, 15, 'Spring', 12.0, 35000, 28000, 'Sector 3'), (46, 16, 'Well', 9.0, 65000, 52000, 'District A'),
(47, 16, 'Borewell', 5.0, 45000, 36000, 'District B'), (48, 16, 'Pond', 40.0, 160000, 128000, 'District C'),
(49, 17, 'River', 70.0, 700000, 560000, 'Zone North'), (50, 17, 'Canal', 45.0, 350000, 280000, 'Zone South'),
(51, 17, 'Tank', 25.0, 95000, 76000, 'Zone East'), (52, 18, 'Spring', 14.0, 38000, 30400, 'Terrace 1'),
(53, 18, 'Well', 10.0, 70000, 56000, 'Terrace 2'), (54, 18, 'Pond', 42.0, 170000, 136000, 'Terrace 3'),
(55, 19, 'Stream', 28.0, 120000, 96000, 'Slope A'), (56, 19, 'Reservoir', 55.0, 450000, 360000, 'Slope B'),
(57, 19, 'Borewell', 6.0, 50000, 40000, 'Slope C'), (58, 20, 'Well', 11.0, 75000, 60000, 'Plain Area'),
(59, 20, 'Canal', 48.0, 380000, 304000, 'Meadow'), (60, 20, 'Pond', 45.0, 180000, 144000, 'Pasture'),
(61, 21, 'River', 75.0, 750000, 600000, 'Ridge Top'), (62, 21, 'Spring', 15.0, 40000, 32000, 'Ridge Bottom'),
(63, 21, 'Tank', 28.0, 105000, 84000, 'Mid Ridge'), (64, 22, 'Well', 12.0, 80000, 64000, 'Canyon North'),
(65, 22, 'Borewell', 7.0, 55000, 44000, 'Canyon South'), (66, 22, 'Stream', 30.0, 130000, 104000, 'Canyon East'),
(67, 23, 'Pond', 48.0, 190000, 152000, 'Summit Base'), (68, 23, 'Reservoir', 60.0, 500000, 400000, 'Summit Mid'),
(69, 23, 'Canal', 50.0, 400000, 320000, 'Summit Top'), (70, 24, 'Spring', 16.0, 42000, 33600, 'Coastal Area');

-- =========================
-- 70 RECORDS FOR HIVE TABLE
-- =========================
INSERT INTO Hive (hive_id, hive_worker_bees, hive_brood, container_id, hive_honey, hive_queen_bee) VALUES
(1, 50000, 10000, 1, 25.5, 'Queen A1'), (2, 52000, 10500, 1, 26.2, 'Queen A2'),
(3, 48000, 9500, 1, 24.8, 'Queen A3'), (4, 51000, 10200, 2, 25.9, 'Queen B1'),
(5, 53000, 10800, 2, 27.1, 'Queen B2'), (6, 49000, 9800, 2, 24.5, 'Queen B3'),
(7, 54000, 11000, 3, 28.3, 'Queen C1'), (8, 56000, 11500, 3, 29.1, 'Queen C2'),
(9, 47000, 9200, 3, 23.9, 'Queen C3'), (10, 55000, 11200, 4, 28.9, 'Queen D1'),
(11, 57000, 11800, 4, 30.2, 'Queen D2'), (12, 46000, 9000, 4, 23.5, 'Queen D3'),
(13, 58000, 12000, 5, 31.5, 'Queen E1'), (14, 59000, 12500, 5, 32.1, 'Queen E2'),
(15, 45000, 8800, 5, 22.8, 'Queen E3'), (16, 60000, 12800, 6, 33.2, 'Queen F1'),
(17, 61000, 13000, 6, 34.5, 'Queen F2'), (18, 44000, 8500, 6, 22.1, 'Queen F3'),
(19, 62000, 13200, 7, 35.8, 'Queen G1'), (20, 63000, 13500, 7, 36.5, 'Queen G2'),
(21, 43000, 8200, 7, 21.5, 'Queen G3'), (22, 64000, 13800, 8, 37.2, 'Queen H1'),
(23, 65000, 14000, 8, 38.1, 'Queen H2'), (24, 42000, 8000, 8, 20.9, 'Queen H3'),
(25, 66000, 14200, 9, 39.5, 'Queen I1'), (26, 67000, 14500, 9, 40.2, 'Queen I2'),
(27, 41000, 7800, 9, 20.2, 'Queen I3'), (28, 68000, 14800, 10, 41.5, 'Queen J1'),
(29, 69000, 15000, 10, 42.8, 'Queen J2'), (30, 40000, 7500, 10, 19.8, 'Queen J3'),
(31, 70000, 15200, 11, 43.5, 'Queen K1'), (32, 71000, 15500, 11, 44.2, 'Queen K2'),
(33, 39000, 7200, 11, 19.1, 'Queen K3'), (34, 72000, 15800, 12, 45.5, 'Queen L1'),
(35, 73000, 16000, 12, 46.8, 'Queen L2'), (36, 38000, 7000, 12, 18.5, 'Queen L3'),
(37, 74000, 16200, 13, 47.5, 'Queen M1'), (38, 75000, 16500, 13, 48.2, 'Queen M2'),
(39, 37000, 6800, 13, 17.9, 'Queen M3'), (40, 76000, 16800, 14, 49.5, 'Queen N1'),
(41, 77000, 17000, 14, 50.2, 'Queen N2'), (42, 36000, 6500, 14, 17.2, 'Queen N3'),
(43, 78000, 17200, 15, 51.5, 'Queen O1'), (44, 79000, 17500, 15, 52.8, 'Queen O2'),
(45, 35000, 6200, 15, 16.5, 'Queen O3'), (46, 80000, 17800, 16, 53.5, 'Queen P1'),
(47, 81000, 18000, 16, 54.2, 'Queen P2'), (48, 34000, 6000, 16, 15.9, 'Queen P3'),
(49, 82000, 18200, 17, 55.5, 'Queen Q1'), (50, 83000, 18500, 17, 56.8, 'Queen Q2'),
(51, 33000, 5800, 17, 15.2, 'Queen Q3'), (52, 84000, 18800, 18, 57.5, 'Queen R1'),
(53, 85000, 19000, 18, 58.2, 'Queen R2'), (54, 32000, 5500, 18, 14.5, 'Queen R3'),
(55, 86000, 19200, 19, 59.5, 'Queen S1'), (56, 87000, 19500, 19, 60.2, 'Queen S2'),
(57, 31000, 5200, 19, 13.8, 'Queen S3'), (58, 88000, 19800, 20, 61.5, 'Queen T1'),
(59, 89000, 20000, 20, 62.2, 'Queen T2'), (60, 30000, 5000, 20, 13.1, 'Queen T3'),
(61, 90000, 20500, 21, 63.5, 'Queen U1'), (62, 91000, 21000, 21, 64.2, 'Queen U2'),
(63, 29000, 4800, 21, 12.5, 'Queen U3'), (64, 92000, 21500, 22, 65.5, 'Queen V1'),
(65, 93000, 22000, 22, 66.2, 'Queen V2'), (66, 28000, 4500, 22, 11.8, 'Queen V3'),
(67, 94000, 22500, 23, 67.5, 'Queen W1'), (68, 95000, 23000, 23, 68.2, 'Queen W2'),
(69, 27000, 4200, 23, 11.1, 'Queen W3'), (70, 96000, 23500, 24, 69.5, 'Queen X1');

-- =========================
-- 70 RECORDS FOR WAREHOUSE TABLE
-- =========================
INSERT INTO warehouse (warehouse_id, location, manager_id) VALUES
('WH001', 'North District Warehouse', 'EMP001'), ('WH002', 'South District Warehouse', 'EMP002'),
('WH003', 'East District Warehouse', 'EMP003'), ('WH004', 'West District Warehouse', 'EMP004'),
('WH005', 'Central Warehouse', 'EMP005'), ('WH006', 'Northwest Storage', 'EMP006'),
('WH007', 'Northeast Storage', 'EMP007'), ('WH008', 'Southwest Storage', 'EMP008'),
('WH009', 'Southeast Storage', 'EMP009'), ('WH010', 'Downtown Facility', 'EMP010'),
('WH011', 'Uptown Facility', 'EMP011'), ('WH012', 'Industrial Zone A', 'EMP012'),
('WH013', 'Industrial Zone B', 'EMP013'), ('WH014', 'Export Warehouse', 'EMP014'),
('WH015', 'Import Warehouse', 'EMP015'), ('WH016', 'Temperature Control A', 'EMP016'),
('WH017', 'Temperature Control B', 'EMP017'), ('WH018', 'Bulk Storage', 'EMP018'),
('WH019', 'Retail Distribution', 'EMP019'), ('WH020', 'Online Fulfillment', 'EMP020'),
('WH021', 'Farm Collection Point', 'EMP021'), ('WH022', 'Processing Facility', 'EMP022'),
('WH023', 'Packaging Warehouse', 'EMP023'), ('WH024', 'Raw Material Storage', 'EMP024'),
('WH025', 'Finished Goods Storage', 'EMP025'), ('WH026', 'Cold Storage Unit 1', 'EMP026'),
('WH027', 'Cold Storage Unit 2', 'EMP027'), ('WH028', 'Ambient Storage', 'EMP028'),
('WH029', 'Hazardous Storage', 'EMP029'), ('WH030', 'Chemical Storage', 'EMP030'),
('WH031', 'Equipment Warehouse', 'EMP031'), ('WH032', 'Spare Parts Storage', 'EMP032'),
('WH033', 'Tool Warehouse', 'EMP033'), ('WH034', 'Packaging Materials', 'EMP034'),
('WH035', 'Label Storage', 'EMP035'), ('WH036', 'Container Storage', 'EMP036'),
('WH037', 'Pallet Storage', 'EMP037'), ('WH038', 'Rack Storage A', 'EMP038'),
('WH039', 'Rack Storage B', 'EMP039'), ('WH040', 'Rack Storage C', 'EMP040'),
('WH041', 'Overflow Warehouse', 'EMP041'), ('WH042', 'Seasonal Storage', 'EMP042'),
('WH043', 'Temporary Storage', 'EMP043'), ('WH044', 'Quarantine Area', 'EMP044'),
('WH045', 'Quality Control Storage', 'EMP045'), ('WH046', 'Sample Storage', 'EMP046'),
('WH047', 'Archive Storage', 'EMP047'), ('WH048', 'Document Storage', 'EMP048'),
('WH049', 'Record Storage', 'EMP049'), ('WH050', 'Backup Facility', 'EMP050'),
('WH051', 'Emergency Storage', 'EMP051'), ('WH052', 'Disaster Recovery', 'EMP052'),
('WH053', 'Mobile Storage 1', 'EMP053'), ('WH054', 'Mobile Storage 2', 'EMP054'),
('WH055', 'Mobile Storage 3', 'EMP055'), ('WH056', 'Port Warehouse', 'EMP056'),
('WH057', 'Airport Warehouse', 'EMP057'), ('WH058', 'Railway Warehouse', 'EMP058'),
('WH059', 'Highway Distribution', 'EMP059'), ('WH060', 'City Center Hub', 'EMP060'),
('WH061', 'Suburban Hub', 'EMP061'), ('WH062', 'Rural Distribution', 'EMP062'),
('WH063', 'Remote Storage', 'EMP063'), ('WH064', 'Island Warehouse', 'EMP064'),
('WH065', 'Border Warehouse', 'EMP065'), ('WH066', 'Free Trade Zone', 'EMP066'),
('WH067', 'Bonded Warehouse', 'EMP067'), ('WH068', 'Private Warehouse', 'EMP068'),
('WH069', 'Shared Facility', 'EMP069'), ('WH070', 'Cooperative Storage', 'EMP070');




INSERT INTO contact_info (employee_id, phone_number, address, city, country) VALUES
('EMP001', '03001111111', '123 Main Street', 'North City', 'Country A'),
('EMP001', '03001111112', '456 Oak Avenue', 'North City', 'Country A'),
('EMP002', '03002222222', '789 Pine Road', 'East City', 'Country A'),
('EMP003', '03003333333', '321 Maple Lane', 'West City', 'Country A'),
('EMP004', '03004444444', '654 Cedar Blvd', 'South City', 'Country A'),
('EMP005', '03005555555', '987 Birch Street', 'Central City', 'Country A'),
('EMP006', '03006666666', '147 Elm Drive', 'North City', 'Country A'),
('EMP007', '03007777777', '258 Spruce Court', 'East City', 'Country A'),
('EMP008', '03008888888', '369 Willow Way', 'West City', 'Country A'),
('EMP009', '03009999999', '741 Ash Avenue', 'South City', 'Country A'),
('EMP010', '03101111111', '852 Poplar Circle', 'Central City', 'Country A'),
('EMP011', '03102222222', '963 Beech Terrace', 'North City', 'Country A'),
('EMP012', '03103333333', '159 Cypress Lane', 'East City', 'Country A'),
('EMP013', '03104444444', '753 Fir Street', 'West City', 'Country A'),
('EMP014', '03105555555', '654 Hemlock Road', 'South City', 'Country A'),
('EMP015', '03106666666', '321 Juniper Blvd', 'Central City', 'Country A'),
('EMP016', '03107777777', '987 Laurel Drive', 'North City', 'Country A'),
('EMP017', '03108888888', '456 Magnolia Court', 'East City', 'Country A'),
('EMP018', '03109999999', '123 Myrtle Avenue', 'West City', 'Country A'),
('EMP019', '03201111111', '789 Oakwood Circle', 'South City', 'Country A'),
('EMP020', '03202222222', '654 Palm Street', 'Central City', 'Country A'),
('EMP021', '03203333333', '321 Quince Lane', 'North City', 'Country A'),
('EMP022', '03204444444', '987 Redwood Road', 'East City', 'Country A'),
('EMP023', '03205555555', '147 Spruce Way', 'West City', 'Country A'),
('EMP024', '03206666666', '258 Sycamore Drive', 'South City', 'Country A'),
('EMP025', '03207777777', '369 Teak Blvd', 'Central City', 'Country A'),
('EMP026', '03208888888', '741 Walnut Court', 'North City', 'Country A'),
('EMP027', '03209999999', '852 Yew Avenue', 'East City', 'Country A'),
('EMP028', '03301111111', '963 Zebrawood Lane', 'West City', 'Country A'),
('EMP029', '03302222222', '159 Alder Street', 'South City', 'Country A'),
('EMP030', '03303333333', '753 Balsa Road', 'Central City', 'Country A'),
('EMP031', '03304444444', '654 Cherry Circle', 'North City', 'Country A'),
('EMP032', '03305555555', '321 Dogwood Drive', 'East City', 'Country A'),
('EMP033', '03306666666', '987 Ebony Court', 'West City', 'Country A'),
('EMP034', '03307777777', '456 Fig Avenue', 'South City', 'Country A'),
('EMP035', '03308888888', '123 Gum Lane', 'Central City', 'Country A'),
('EMP036', '03309999999', '789 Hazel Street', 'North City', 'Country A'),
('EMP037', '03401111111', '654 Ironwood Road', 'East City', 'Country A'),
('EMP038', '03402222222', '321 Jacaranda Way', 'West City', 'Country A'),
('EMP039', '03403333333', '987 Koa Drive', 'South City', 'Country A'),
('EMP040', '03404444444', '147 Larch Blvd', 'Central City', 'Country A'),
('EMP041', '03405555555', '258 Mahogany Court', 'North City', 'Country A'),
('EMP042', '03406666666', '369 Nectarine Lane', 'East City', 'Country A'),
('EMP043', '03407777777', '741 Olive Avenue', 'West City', 'Country A'),
('EMP044', '03408888888', '852 Pear Street', 'South City', 'Country A'),
('EMP045', '03409999999', '963 Quince Circle', 'Central City', 'Country A'),
('EMP046', '03501111111', '159 Rosewood Drive', 'North City', 'Country A'),
('EMP047', '03502222222', '753 Sandalwood Court', 'East City', 'Country A'),
('EMP048', '03503333333', '654 Teakwood Lane', 'West City', 'Country A'),
('EMP049', '03504444444', '321 Uva Avenue', 'South City', 'Country A'),
('EMP050', '03505555555', '987 Vine Street', 'Central City', 'Country A'),
('EMP051', '03506666666', '456 Willowmere Road', 'North City', 'Country A'),
('EMP052', '03507777777', '123 Xanadu Way', 'East City', 'Country A'),
('EMP053', '03508888888', '789 Yarrow Drive', 'West City', 'Country A'),
('EMP054', '03509999999', '654 Zinnia Blvd', 'South City', 'Country A'),
('EMP055', '03601111111', '321 Apricot Court', 'Central City', 'Country A'),
('EMP056', '03602222222', '987 Banana Lane', 'North City', 'Country A'),
('EMP057', '03603333333', '147 Coconut Avenue', 'East City', 'Country A'),
('EMP058', '03604444444', '258 Date Street', 'West City', 'Country A'),
('EMP059', '03605555555', '369 Elderberry Circle', 'South City', 'Country A'),
('EMP060', '03606666666', '741 Fig Drive', 'Central City', 'Country A'),
('EMP061', '03607777777', '852 Grape Court', 'North City', 'Country A'),
('EMP062', '03608888888', '963 Hawthorn Lane', 'East City', 'Country A'),
('EMP063', '03609999999', '159 Indigo Road', 'West City', 'Country A'),
('EMP064', '03701111111', '753 Jujube Way', 'South City', 'Country A'),
('EMP065', '03702222222', '654 Kiwi Avenue', 'Central City', 'Country A'),
('EMP066', '03703333333', '321 Lemon Street', 'North City', 'Country A'),
('EMP067', '03704444444', '987 Mango Drive', 'East City', 'Country A'),
('EMP068', '03705555555', '456 Nectarine Blvd', 'West City', 'Country A'),
('EMP069', '03706666666', '123 Orange Court', 'South City', 'Country A'),
('EMP070', '03707777777', '789 Papaya Lane', 'Central City', 'Country A');

-- =========================
-- 70 RECORDS FOR SALARY_RECORD
-- =========================
INSERT INTO salary_record (employee_id, salary_month, salary_year, basic_salary, bonus, deduction, net_salary) VALUES
('EMP001', 1, 2024, 50000, 5000, 1000, 54000), ('EMP002', 1, 2024, 45000, 4000, 900, 48100),
('EMP003', 1, 2024, 48000, 4500, 950, 51550), ('EMP004', 1, 2024, 47000, 4200, 920, 50280),
('EMP005', 1, 2024, 46000, 4100, 910, 49190), ('EMP006', 1, 2024, 49000, 4800, 980, 52820),
('EMP007', 1, 2024, 40000, 3000, 800, 42200), ('EMP008', 1, 2024, 42000, 3200, 840, 44360),
('EMP009', 1, 2024, 41000, 3100, 820, 43280), ('EMP010', 1, 2024, 35000, 2000, 700, 36300),
('EMP011', 1, 2024, 25000, 1000, 500, 25500), ('EMP012', 1, 2024, 38000, 2500, 760, 39740),
('EMP013', 1, 2024, 36000, 2200, 720, 37480), ('EMP014', 1, 2024, 37000, 2300, 740, 38560),
('EMP015', 1, 2024, 34000, 1800, 680, 35120), ('EMP016', 1, 2024, 39000, 2800, 780, 41020),
('EMP017', 1, 2024, 33000, 1700, 660, 34040), ('EMP018', 1, 2024, 38000, 2500, 760, 39740),
('EMP019', 1, 2024, 26000, 1100, 520, 26580), ('EMP020', 1, 2024, 40000, 3000, 800, 42200),
('EMP021', 1, 2024, 32000, 1600, 640, 32960), ('EMP022', 1, 2024, 43000, 3500, 860, 45640),
('EMP023', 1, 2024, 37000, 2300, 740, 38560), ('EMP024', 1, 2024, 36000, 2200, 720, 37480),
('EMP025', 1, 2024, 35000, 2000, 700, 36300), ('EMP026', 1, 2024, 34000, 1800, 680, 35120),
('EMP027', 1, 2024, 39000, 2800, 780, 41020), ('EMP028', 1, 2024, 38000, 2500, 760, 39740),
('EMP029', 1, 2024, 37000, 2300, 740, 38560), ('EMP030', 1, 2024, 36000, 2200, 720, 37480),
('EMP031', 1, 2024, 35000, 2000, 700, 36300), ('EMP032', 1, 2024, 34000, 1800, 680, 35120),
('EMP033', 1, 2024, 33000, 1700, 660, 34040), ('EMP034', 1, 2024, 32000, 1600, 640, 32960),
('EMP035', 1, 2024, 31000, 1500, 620, 31880), ('EMP036', 1, 2024, 30000, 1400, 600, 30800),
('EMP037', 1, 2024, 29000, 1300, 580, 29720), ('EMP038', 1, 2024, 28000, 1200, 560, 28640),
('EMP039', 1, 2024, 27000, 1100, 540, 27560), ('EMP040', 1, 2024, 26000, 1000, 520, 26480),
('EMP041', 1, 2024, 25000, 900, 500, 25400), ('EMP042', 1, 2024, 24000, 800, 480, 24320),
('EMP043', 1, 2024, 23000, 700, 460, 23240), ('EMP044', 1, 2024, 22000, 600, 440, 22160),
('EMP045', 1, 2024, 21000, 500, 420, 21080), ('EMP046', 1, 2024, 20000, 400, 400, 20000),
('EMP047', 1, 2024, 19000, 300, 380, 18920), ('EMP048', 1, 2024, 18000, 200, 360, 17840),
('EMP049', 1, 2024, 17000, 100, 340, 16760), ('EMP050', 1, 2024, 16000, 0, 320, 15680),
('EMP051', 2, 2024, 50000, 5000, 1000, 54000), ('EMP052', 2, 2024, 45000, 4000, 900, 48100),
('EMP053', 2, 2024, 48000, 4500, 950, 51550), ('EMP054', 2, 2024, 47000, 4200, 920, 50280),
('EMP055', 2, 2024, 46000, 4100, 910, 49190), ('EMP056', 2, 2024, 49000, 4800, 980, 52820),
('EMP057', 2, 2024, 40000, 3000, 800, 42200), ('EMP058', 2, 2024, 42000, 3200, 840, 44360),
('EMP059', 2, 2024, 41000, 3100, 820, 43280), ('EMP060', 2, 2024, 35000, 2000, 700, 36300),
('EMP061', 2, 2024, 25000, 1000, 500, 25500), ('EMP062', 2, 2024, 38000, 2500, 760, 39740),
('EMP063', 2, 2024, 36000, 2200, 720, 37480), ('EMP064', 2, 2024, 37000, 2300, 740, 38560),
('EMP065', 2, 2024, 34000, 1800, 680, 35120), ('EMP066', 2, 2024, 39000, 2800, 780, 41020),
('EMP067', 2, 2024, 33000, 1700, 660, 34040), ('EMP068', 2, 2024, 38000, 2500, 760, 39740),
('EMP069', 2, 2024, 26000, 1100, 520, 26580), ('EMP070', 2, 2024, 40000, 3000, 800, 42200);

-- =========================
-- 70 RECORDS FOR ATTENDANCE_RECORD
-- =========================
INSERT INTO attendance_record (employee_id, attendance_date, working_hours, attendance_status) VALUES
('EMP001', '2024-01-01', 8.5, 'Present'), ('EMP002', '2024-01-01', 8.0, 'Present'), ('EMP003', '2024-01-01', 8.5, 'Present'),
('EMP004', '2024-01-01', 8.0, 'Present'), ('EMP005', '2024-01-01', 7.5, 'Present'), ('EMP006', '2024-01-01', 8.0, 'Present'),
('EMP007', '2024-01-01', 8.5, 'Present'), ('EMP008', '2024-01-01', 9.0, 'Present'), ('EMP009', '2024-01-01', 8.0, 'Present'),
('EMP010', '2024-01-01', 8.0, 'Present'), ('EMP011', '2024-01-01', 0.0, 'Absent'), ('EMP012', '2024-01-01', 8.5, 'Present'),
('EMP013', '2024-01-01', 8.0, 'Present'), ('EMP014', '2024-01-01', 8.0, 'Present'), ('EMP015', '2024-01-01', 7.5, 'Present'),
('EMP016', '2024-01-01', 8.0, 'Present'), ('EMP017', '2024-01-01', 8.0, 'Present'), ('EMP018', '2024-01-01', 8.5, 'Present'),
('EMP019', '2024-01-01', 0.0, 'Leave'), ('EMP020', '2024-01-01', 8.0, 'Present'), ('EMP021', '2024-01-02', 8.0, 'Present'),
('EMP022', '2024-01-02', 8.5, 'Present'), ('EMP023', '2024-01-02', 8.0, 'Present'), ('EMP024', '2024-01-02', 8.0, 'Present'),
('EMP025', '2024-01-02', 7.5, 'Present'), ('EMP026', '2024-01-02', 8.0, 'Present'), ('EMP027', '2024-01-02', 8.5, 'Present'),
('EMP028', '2024-01-02', 9.0, 'Present'), ('EMP029', '2024-01-02', 8.0, 'Present'), ('EMP030', '2024-01-02', 8.0, 'Present'),
('EMP031', '2024-01-02', 0.0, 'Absent'), ('EMP032', '2024-01-02', 8.5, 'Present'), ('EMP033', '2024-01-02', 8.0, 'Present'),
('EMP034', '2024-01-02', 8.0, 'Present'), ('EMP035', '2024-01-02', 7.5, 'Present'), ('EMP036', '2024-01-02', 8.0, 'Present'),
('EMP037', '2024-01-02', 8.0, 'Present'), ('EMP038', '2024-01-02', 8.5, 'Present'), ('EMP039', '2024-01-02', 0.0, 'Leave'),
('EMP040', '2024-01-02', 8.0, 'Present'), ('EMP041', '2024-01-03', 8.0, 'Present'), ('EMP042', '2024-01-03', 8.5, 'Present'),
('EMP043', '2024-01-03', 8.0, 'Present'), ('EMP044', '2024-01-03', 8.0, 'Present'), ('EMP045', '2024-01-03', 7.5, 'Present'),
('EMP046', '2024-01-03', 8.0, 'Present'), ('EMP047', '2024-01-03', 8.5, 'Present'), ('EMP048', '2024-01-03', 9.0, 'Present'),
('EMP049', '2024-01-03', 8.0, 'Present'), ('EMP050', '2024-01-03', 8.0, 'Present'), ('EMP051', '2024-01-03', 0.0, 'Absent'),
('EMP052', '2024-01-03', 8.5, 'Present'), ('EMP053', '2024-01-03', 8.0, 'Present'), ('EMP054', '2024-01-03', 8.0, 'Present'),
('EMP055', '2024-01-03', 7.5, 'Present'), ('EMP056', '2024-01-03', 8.0, 'Present'), ('EMP057', '2024-01-03', 8.0, 'Present'),
('EMP058', '2024-01-03', 8.5, 'Present'), ('EMP059', '2024-01-03', 0.0, 'Leave'), ('EMP060', '2024-01-03', 8.0, 'Present'),
('EMP061', '2024-01-04', 8.0, 'Present'), ('EMP062', '2024-01-04', 8.5, 'Present'), ('EMP063', '2024-01-04', 8.0, 'Present'),
('EMP064', '2024-01-04', 8.0, 'Present'), ('EMP065', '2024-01-04', 7.5, 'Present'), ('EMP066', '2024-01-04', 8.0, 'Present'),
('EMP067', '2024-01-04', 8.5, 'Present'), ('EMP068', '2024-01-04', 9.0, 'Present'), ('EMP069', '2024-01-04', 8.0, 'Present'),
('EMP070', '2024-01-04', 8.0, 'Present');

-- =========================
-- 70 RECORDS FOR SALARY_TRANSACTION
-- =========================
INSERT INTO salary_transaction (employee_id, salary_month, salary_year, transaction_date, transaction_amount, transaction_method) VALUES
('EMP001', 1, 2024, '2024-01-31', 54000, 'Bank'), ('EMP002', 1, 2024, '2024-01-31', 48100, 'Bank'),
('EMP003', 1, 2024, '2024-01-31', 51550, 'Online'), ('EMP004', 1, 2024, '2024-01-31', 50280, 'Bank'),
('EMP005', 1, 2024, '2024-01-31', 49190, 'Cash'), ('EMP006', 1, 2024, '2024-01-31', 52820, 'Bank'),
('EMP007', 1, 2024, '2024-01-31', 42200, 'Online'), ('EMP008', 1, 2024, '2024-01-31', 44360, 'Bank'),
('EMP009', 1, 2024, '2024-01-31', 43280, 'Bank'), ('EMP010', 1, 2024, '2024-01-31', 36300, 'Cash'),
('EMP011', 1, 2024, '2024-01-31', 25500, 'Bank'), ('EMP012', 1, 2024, '2024-01-31', 39740, 'Online'),
('EMP013', 1, 2024, '2024-01-31', 37480, 'Bank'), ('EMP014', 1, 2024, '2024-01-31', 38560, 'Bank'),
('EMP015', 1, 2024, '2024-01-31', 35120, 'Cash'), ('EMP016', 1, 2024, '2024-01-31', 41020, 'Bank'),
('EMP017', 1, 2024, '2024-01-31', 34040, 'Online'), ('EMP018', 1, 2024, '2024-01-31', 39740, 'Bank'),
('EMP019', 1, 2024, '2024-01-31', 26580, 'Cash'), ('EMP020', 1, 2024, '2024-01-31', 42200, 'Bank'),
('EMP021', 1, 2024, '2024-01-31', 32960, 'Bank'), ('EMP022', 1, 2024, '2024-01-31', 45640, 'Online'),
('EMP023', 1, 2024, '2024-01-31', 38560, 'Bank'), ('EMP024', 1, 2024, '2024-01-31', 37480, 'Bank'),
('EMP025', 1, 2024, '2024-01-31', 36300, 'Cash'), ('EMP026', 1, 2024, '2024-01-31', 35120, 'Bank'),
('EMP027', 1, 2024, '2024-01-31', 41020, 'Online'), ('EMP028', 1, 2024, '2024-01-31', 39740, 'Bank'),
('EMP029', 1, 2024, '2024-01-31', 38560, 'Bank'), ('EMP030', 1, 2024, '2024-01-31', 37480, 'Cash'),
('EMP031', 1, 2024, '2024-01-31', 36300, 'Bank'), ('EMP032', 1, 2024, '2024-01-31', 35120, 'Bank'),
('EMP033', 1, 2024, '2024-01-31', 34040, 'Online'), ('EMP034', 1, 2024, '2024-01-31', 32960, 'Bank'),
('EMP035', 1, 2024, '2024-01-31', 31880, 'Cash'), ('EMP036', 1, 2024, '2024-01-31', 30800, 'Bank'),
('EMP037', 1, 2024, '2024-01-31', 29720, 'Bank'), ('EMP038', 1, 2024, '2024-01-31', 28640, 'Online'),
('EMP039', 1, 2024, '2024-01-31', 27560, 'Bank'), ('EMP040', 1, 2024, '2024-01-31', 26480, 'Cash'),
('EMP041', 1, 2024, '2024-01-31', 25400, 'Bank'), ('EMP042', 1, 2024, '2024-01-31', 24320, 'Bank'),
('EMP043', 1, 2024, '2024-01-31', 23240, 'Online'), ('EMP044', 1, 2024, '2024-01-31', 22160, 'Bank'),
('EMP045', 1, 2024, '2024-01-31', 21080, 'Cash'), ('EMP046', 1, 2024, '2024-01-31', 20000, 'Bank'),
('EMP047', 1, 2024, '2024-01-31', 18920, 'Bank'), ('EMP048', 1, 2024, '2024-01-31', 17840, 'Online'),
('EMP049', 1, 2024, '2024-01-31', 16760, 'Bank'), ('EMP050', 1, 2024, '2024-01-31', 15680, 'Cash'),
('EMP051', 2, 2024, '2024-02-29', 54000, 'Bank'), ('EMP052', 2, 2024, '2024-02-29', 48100, 'Online'),
('EMP053', 2, 2024, '2024-02-29', 51550, 'Bank'), ('EMP054', 2, 2024, '2024-02-29', 50280, 'Cash'),
('EMP055', 2, 2024, '2024-02-29', 49190, 'Bank'), ('EMP056', 2, 2024, '2024-02-29', 52820, 'Bank'),
('EMP057', 2, 2024, '2024-02-29', 42200, 'Online'), ('EMP058', 2, 2024, '2024-02-29', 44360, 'Bank'),
('EMP059', 2, 2024, '2024-02-29', 43280, 'Cash'), ('EMP060', 2, 2024, '2024-02-29', 36300, 'Bank'),
('EMP061', 2, 2024, '2024-02-29', 25500, 'Bank'), ('EMP062', 2, 2024, '2024-02-29', 39740, 'Online'),
('EMP063', 2, 2024, '2024-02-29', 37480, 'Bank'), ('EMP064', 2, 2024, '2024-02-29', 38560, 'Cash'),
('EMP065', 2, 2024, '2024-02-29', 35120, 'Bank'), ('EMP066', 2, 2024, '2024-02-29', 41020, 'Bank'),
('EMP067', 2, 2024, '2024-02-29', 34040, 'Online'), ('EMP068', 2, 2024, '2024-02-29', 39740, 'Bank'),
('EMP069', 2, 2024, '2024-02-29', 26580, 'Cash'), ('EMP070', 2, 2024, '2024-02-29', 42200, 'Bank');

-- =========================
-- 70 RECORDS FOR REPORT
-- =========================
INSERT INTO report (report_id, department_id, employee_id, report_date, report_type, report_content) VALUES
('RPT001', 'D001', 'EMP001', '2024-01-05', 'Monthly', 'Farm production report January'),
('RPT002', 'D002', 'EMP002', '2024-01-05', 'Quality', 'Honey quality analysis report'),
('RPT003', 'D003', 'EMP003', '2024-01-05', 'Sales', 'Monthly sales performance'),
('RPT004', 'D004', 'EMP004', '2024-01-05', 'HR', 'Employee attendance summary'),
('RPT005', 'D005', 'EMP005', '2024-01-05', 'Packing', 'Packing efficiency report'),
('RPT006', 'D006', 'EMP006', '2024-01-05', 'Resource', 'Resource utilization report'),
('RPT007', 'D001', 'EMP007', '2024-01-10', 'Weekly', 'Farm operations weekly'),
('RPT008', 'D002', 'EMP008', '2024-01-10', 'Production', 'Honey extraction report'),
('RPT009', 'D003', 'EMP009', '2024-01-10', 'Revenue', 'Revenue analysis'),
('RPT010', 'D004', 'EMP016', '2024-01-10', 'Recruitment', 'Recruitment status'),
('RPT011', 'D001', 'EMP010', '2024-01-15', 'Maintenance', 'Equipment maintenance log'),
('RPT012', 'D002', 'EMP012', '2024-01-15', 'Testing', 'Lab test results'),
('RPT013', 'D003', 'EMP014', '2024-01-15', 'Customer', 'Customer feedback'),
('RPT014', 'D004', 'EMP017', '2024-01-15', 'Payroll', 'Payroll summary'),
('RPT015', 'D005', 'EMP018', '2024-01-15', 'Inventory', 'Packing inventory'),
('RPT016', 'D006', 'EMP020', '2024-01-15', 'Stock', 'Stock level report'),
('RPT017', 'D001', 'EMP001', '2024-02-05', 'Monthly', 'Farm production report February'),
('RPT018', 'D002', 'EMP002', '2024-02-05', 'Quality', 'Honey quality analysis February'),
('RPT019', 'D003', 'EMP003', '2024-02-05', 'Sales', 'Monthly sales performance February'),
('RPT020', 'D004', 'EMP004', '2024-02-05', 'HR', 'Employee attendance summary February'),
('RPT021', 'D005', 'EMP005', '2024-02-05', 'Packing', 'Packing efficiency report February'),
('RPT022', 'D006', 'EMP006', '2024-02-05', 'Resource', 'Resource utilization February'),
('RPT023', 'D001', 'EMP007', '2024-02-10', 'Weekly', 'Farm operations weekly Feb'),
('RPT024', 'D002', 'EMP008', '2024-02-10', 'Production', 'Honey extraction Feb report'),
('RPT025', 'D003', 'EMP009', '2024-02-10', 'Revenue', 'Revenue analysis February'),
('RPT026', 'D004', 'EMP016', '2024-02-10', 'Recruitment', 'Recruitment status Feb'),
('RPT027', 'D001', 'EMP010', '2024-02-15', 'Maintenance', 'Equipment maintenance Feb'),
('RPT028', 'D002', 'EMP012', '2024-02-15', 'Testing', 'Lab test results Feb'),
('RPT029', 'D003', 'EMP014', '2024-02-15', 'Customer', 'Customer feedback Feb'),
('RPT030', 'D004', 'EMP017', '2024-02-15', 'Payroll', 'Payroll summary February'),
('RPT031', 'D005', 'EMP018', '2024-02-15', 'Inventory', 'Packing inventory Feb'),
('RPT032', 'D006', 'EMP020', '2024-02-15', 'Stock', 'Stock level report Feb'),
('RPT033', 'D001', 'EMP001', '2024-03-05', 'Monthly', 'Farm production report March'),
('RPT034', 'D002', 'EMP002', '2024-03-05', 'Quality', 'Honey quality analysis March'),
('RPT035', 'D003', 'EMP003', '2024-03-05', 'Sales', 'Monthly sales performance March'),
('RPT036', 'D004', 'EMP004', '2024-03-05', 'HR', 'Employee attendance summary March'),
('RPT037', 'D005', 'EMP005', '2024-03-05', 'Packing', 'Packing efficiency report March'),
('RPT038', 'D006', 'EMP006', '2024-03-05', 'Resource', 'Resource utilization March'),
('RPT039', 'D001', 'EMP007', '2024-03-10', 'Weekly', 'Farm operations weekly Mar'),
('RPT040', 'D002', 'EMP008', '2024-03-10', 'Production', 'Honey extraction Mar report'),
('RPT041', 'D003', 'EMP009', '2024-03-10', 'Revenue', 'Revenue analysis March'),
('RPT042', 'D004', 'EMP016', '2024-03-10', 'Recruitment', 'Recruitment status Mar'),
('RPT043', 'D001', 'EMP010', '2024-03-15', 'Maintenance', 'Equipment maintenance Mar'),
('RPT044', 'D002', 'EMP012', '2024-03-15', 'Testing', 'Lab test results March'),
('RPT045', 'D003', 'EMP014', '2024-03-15', 'Customer', 'Customer feedback March'),
('RPT046', 'D004', 'EMP017', '2024-03-15', 'Payroll', 'Payroll summary March'),
('RPT047', 'D005', 'EMP018', '2024-03-15', 'Inventory', 'Packing inventory Mar'),
('RPT048', 'D006', 'EMP020', '2024-03-15', 'Stock', 'Stock level report Mar'),
('RPT049', 'D001', 'EMP025', '2024-04-05', 'Quarterly', 'Q1 Farm production summary'),
('RPT050', 'D002', 'EMP027', '2024-04-05', 'Quarterly', 'Q1 Quality analysis summary'),
('RPT051', 'D003', 'EMP029', '2024-04-05', 'Quarterly', 'Q1 Sales performance summary'),
('RPT052', 'D004', 'EMP030', '2024-04-05', 'Quarterly', 'Q1 HR summary'),
('RPT053', 'D005', 'EMP032', '2024-04-05', 'Quarterly', 'Q1 Packing summary'),
('RPT054', 'D006', 'EMP034', '2024-04-05', 'Quarterly', 'Q1 Resource summary'),
('RPT055', 'D001', 'EMP036', '2024-04-10', 'Weekly', 'Farm operations weekly Apr'),
('RPT056', 'D002', 'EMP038', '2024-04-10', 'Production', 'Honey extraction Apr report'),
('RPT057', 'D003', 'EMP039', '2024-04-10', 'Revenue', 'Revenue analysis April'),
('RPT058', 'D004', 'EMP040', '2024-04-10', 'Recruitment', 'Recruitment status Apr'),
('RPT059', 'D001', 'EMP041', '2024-04-15', 'Maintenance', 'Equipment maintenance Apr'),
('RPT060', 'D002', 'EMP042', '2024-04-15', 'Testing', 'Lab test results April'),
('RPT061', 'D003', 'EMP043', '2024-04-15', 'Customer', 'Customer feedback April'),
('RPT062', 'D004', 'EMP044', '2024-04-15', 'Payroll', 'Payroll summary April'),
('RPT063', 'D005', 'EMP045', '2024-04-15', 'Inventory', 'Packing inventory Apr'),
('RPT064', 'D006', 'EMP046', '2024-04-15', 'Stock', 'Stock level report Apr'),
('RPT065', 'D001', 'EMP047', '2024-05-05', 'Monthly', 'Farm production report May'),
('RPT066', 'D002', 'EMP048', '2024-05-05', 'Quality', 'Honey quality analysis May'),
('RPT067', 'D003', 'EMP049', '2024-05-05', 'Sales', 'Monthly sales performance May'),
('RPT068', 'D004', 'EMP050', '2024-05-05', 'HR', 'Employee attendance summary May'),
('RPT069', 'D005', 'EMP051', '2024-05-05', 'Packing', 'Packing efficiency report May'),
('RPT070', 'D006', 'EMP052', '2024-05-05', 'Resource', 'Resource utilization May');

-- =========================
-- 70 RECORDS FOR ALERT
-- =========================
INSERT INTO alert (alert_id, report_id, employee_id, alert_type, alert_description, alert_date) VALUES
('ALT001', 'RPT001', 'EMP001', 'Low Stock', 'Farm equipment needs maintenance', '2024-01-06'),
('ALT002', 'RPT002', 'EMP002', 'Quality', 'Honey purity below standard', '2024-01-06'),
('ALT003', 'RPT003', 'EMP003', 'Sales', 'Sales target not met', '2024-01-06'),
('ALT004', 'RPT004', 'EMP004', 'HR', 'Attendance issue detected', '2024-01-06'),
('ALT005', 'RPT005', 'EMP005', 'Packing', 'Packing machine error', '2024-01-06'),
('ALT006', 'RPT006', 'EMP006', 'Resource', 'Resource shortage', '2024-01-06'),
('ALT007', 'RPT007', 'EMP007', 'Weather', 'Bad weather forecast', '2024-01-11'),
('ALT008', 'RPT008', 'EMP008', 'Production', 'Extraction delay', '2024-01-11'),
('ALT009', 'RPT009', 'EMP009', 'Revenue', 'Revenue decreased', '2024-01-11'),
('ALT010', 'RPT010', 'EMP016', 'Recruitment', 'Vacancy not filled', '2024-01-11'),
('ALT011', 'RPT011', 'EMP010', 'Maintenance', 'Equipment breakdown', '2024-01-16'),
('ALT012', 'RPT012', 'EMP012', 'Testing', 'Failed quality test', '2024-01-16'),
('ALT013', 'RPT013', 'EMP014', 'Customer', 'Customer complaint', '2024-01-16'),
('ALT014', 'RPT014', 'EMP017', 'Payroll', 'Payroll discrepancy', '2024-01-16'),
('ALT015', 'RPT015', 'EMP018', 'Inventory', 'Low packing materials', '2024-01-16'),
('ALT016', 'RPT016', 'EMP020', 'Stock', 'Stock below threshold', '2024-01-16'),
('ALT017', 'RPT017', 'EMP001', 'Low Stock', 'Farm supply shortage', '2024-02-06'),
('ALT018', 'RPT018', 'EMP002', 'Quality', 'Moisture content high', '2024-02-06'),
('ALT019', 'RPT019', 'EMP003', 'Sales', 'New competitor entered', '2024-02-06'),
('ALT020', 'RPT020', 'EMP004', 'HR', 'Staff shortage', '2024-02-06'),
('ALT021', 'RPT021', 'EMP005', 'Packing', 'Labeling machine error', '2024-02-06'),
('ALT022', 'RPT022', 'EMP006', 'Resource', 'Vehicle breakdown', '2024-02-06'),
('ALT023', 'RPT023', 'EMP007', 'Weather', 'Heavy rain alert', '2024-02-11'),
('ALT024', 'RPT024', 'EMP008', 'Production', 'Filter clogged', '2024-02-11'),
('ALT025', 'RPT025', 'EMP009', 'Revenue', 'Payment delays', '2024-02-11'),
('ALT026', 'RPT026', 'EMP016', 'Recruitment', 'Interview no-shows', '2024-02-11'),
('ALT027', 'RPT027', 'EMP010', 'Maintenance', 'Tractor repair needed', '2024-02-16'),
('ALT028', 'RPT028', 'EMP012', 'Testing', 'Contamination found', '2024-02-16'),
('ALT029', 'RPT029', 'EMP014', 'Customer', 'Order cancellation', '2024-02-16'),
('ALT030', 'RPT030', 'EMP017', 'Payroll', 'Tax calculation error', '2024-02-16'),
('ALT031', 'RPT031', 'EMP018', 'Inventory', 'Box shortage', '2024-02-16'),
('ALT032', 'RPT032', 'EMP020', 'Stock', 'Overstock alert', '2024-02-16'),
('ALT033', 'RPT033', 'EMP001', 'Low Stock', 'Fertilizer low', '2024-03-06'),
('ALT034', 'RPT034', 'EMP002', 'Quality', 'Color variation detected', '2024-03-06'),
('ALT035', 'RPT035', 'EMP003', 'Sales', 'Low demand season', '2024-03-06'),
('ALT036', 'RPT036', 'EMP004', 'HR', 'Training needed', '2024-03-06'),
('ALT037', 'RPT037', 'EMP005', 'Packing', 'Sealing issue', '2024-03-06'),
('ALT038', 'RPT038', 'EMP006', 'Resource', 'Fuel shortage', '2024-03-06'),
('ALT039', 'RPT039', 'EMP007', 'Weather', 'High temperature warning', '2024-03-11'),
('ALT040', 'RPT040', 'EMP008', 'Production', 'Low honey flow', '2024-03-11'),
('ALT041', 'RPT041', 'EMP009', 'Revenue', 'Profit margin low', '2024-03-11'),
('ALT042', 'RPT042', 'EMP016', 'Recruitment', 'Offer declined', '2024-03-11'),
('ALT043', 'RPT043', 'EMP010', 'Maintenance', 'Generator failure', '2024-03-16'),
('ALT044', 'RPT044', 'EMP012', 'Testing', 'pH level abnormal', '2024-03-16'),
('ALT045', 'RPT045', 'EMP014', 'Customer', 'Late delivery complaint', '2024-03-16'),
('ALT046', 'RPT046', 'EMP017', 'Payroll', 'Bank account change', '2024-03-16'),
('ALT047', 'RPT047', 'EMP018', 'Inventory', 'Lid shortage', '2024-03-16'),
('ALT048', 'RPT048', 'EMP020', 'Stock', 'Expiry approaching', '2024-03-16'),
('ALT049', 'RPT049', 'EMP025', 'Quarterly', 'Targets not met', '2024-04-06'),
('ALT050', 'RPT050', 'EMP027', 'Quarterly', 'Quality downgrade', '2024-04-06'),
('ALT051', 'RPT051', 'EMP029', 'Quarterly', 'Sales decline', '2024-04-06'),
('ALT052', 'RPT052', 'EMP030', 'Quarterly', 'High turnover rate', '2024-04-06'),
('ALT053', 'RPT053', 'EMP032', 'Quarterly', 'Wastage increase', '2024-04-06'),
('ALT054', 'RPT054', 'EMP034', 'Quarterly', 'Budget overshoot', '2024-04-06'),
('ALT055', 'RPT055', 'EMP036', 'Weather', 'Storm warning', '2024-04-11'),
('ALT056', 'RPT056', 'EMP038', 'Production', 'Machine calibration needed', '2024-04-11'),
('ALT057', 'RPT057', 'EMP039', 'Revenue', 'Collection pending', '2024-04-11'),
('ALT058', 'RPT058', 'EMP040', 'Recruitment', 'Skill gap identified', '2024-04-11'),
('ALT059', 'RPT059', 'EMP041', 'Maintenance', 'Belt replacement needed', '2024-04-16'),
('ALT060', 'RPT060', 'EMP042', 'Testing', 'Bacterial presence', '2024-04-16'),
('ALT061', 'RPT061', 'EMP043', 'Customer', 'Return request', '2024-04-16'),
('ALT062', 'RPT062', 'EMP044', 'Payroll', 'Overtime calculation', '2024-04-16'),
('ALT063', 'RPT063', 'EMP045', 'Inventory', 'Label shortage', '2024-04-16'),
('ALT064', 'RPT064', 'EMP046', 'Stock', 'Space constraint', '2024-04-16'),
('ALT065', 'RPT065', 'EMP047', 'Low Stock', 'Seeds low', '2024-05-06'),
('ALT066', 'RPT066', 'EMP048', 'Quality', 'Adulteration suspected', '2024-05-06'),
('ALT067', 'RPT067', 'EMP049', 'Sales', 'Price competition', '2024-05-06'),
('ALT068', 'RPT068', 'EMP050', 'HR', 'Complaint filed', '2024-05-06'),
('ALT069', 'RPT069', 'EMP051', 'Packing', 'Weight variation', '2024-05-06'),
('ALT070', 'RPT070', 'EMP052', 'Resource', 'Electricity outage', '2024-05-06');

-- =========================
-- 70 RECORDS FOR NOTIFICATION
-- =========================
INSERT INTO notification (notification_id, alert_id, department_id, notification_type, message, notify_date) VALUES
('NOT001', 'ALT001', 'D001', 'RESOURCE', 'Farm equipment needs immediate maintenance', '2024-01-07'),
('NOT002', 'ALT002', 'D002', 'HR', 'Quality alert: Honey purity below standard', '2024-01-07'),
('NOT003', 'ALT003', 'D003', 'RESOURCE', 'Sales team needs to improve performance', '2024-01-07'),
('NOT004', 'ALT004', 'D004', 'HR', 'Attendance issue requires attention', '2024-01-07'),
('NOT005', 'ALT005', 'D005', 'RESOURCE', 'Packing machine requires repair', '2024-01-07'),
('NOT006', 'ALT006', 'D006', 'HR', 'Resource shortage reported', '2024-01-07'),
('NOT007', 'ALT007', 'D001', 'RESOURCE', 'Weather alert: Prepare for bad weather', '2024-01-12'),
('NOT008', 'ALT008', 'D002', 'HR', 'Production delay notification', '2024-01-12'),
('NOT009', 'ALT009', 'D003', 'RESOURCE', 'Revenue decrease alert', '2024-01-12'),
('NOT010', 'ALT010', 'D004', 'HR', 'Urgent: Vacancy needs to be filled', '2024-01-12'),
('NOT011', 'ALT011', 'D001', 'RESOURCE', 'Equipment breakdown - Action required', '2024-01-17'),
('NOT012', 'ALT012', 'D002', 'HR', 'Quality test failed - Immediate action', '2024-01-17'),
('NOT013', 'ALT013', 'D003', 'RESOURCE', 'Customer complaint needs resolution', '2024-01-17'),
('NOT014', 'ALT014', 'D004', 'HR', 'Payroll error needs correction', '2024-01-17'),
('NOT015', 'ALT015', 'D005', 'RESOURCE', 'Packing materials low - Order now', '2024-01-17'),
('NOT016', 'ALT016', 'D006', 'HR', 'Stock below threshold - Reorder', '2024-01-17'),
('NOT017', 'ALT017', 'D001', 'RESOURCE', 'Farm supply shortage alert', '2024-02-07'),
('NOT018', 'ALT018', 'D002', 'HR', 'Moisture content high - Check process', '2024-02-07'),
('NOT019', 'ALT019', 'D003', 'RESOURCE', 'New competitor - Strategy needed', '2024-02-07'),
('NOT020', 'ALT020', 'D004', 'HR', 'Staff shortage - Hire urgently', '2024-02-07'),
('NOT021', 'ALT021', 'D005', 'RESOURCE', 'Labeling machine error reported', '2024-02-07'),
('NOT022', 'ALT022', 'D006', 'HR', 'Vehicle breakdown - Arrange transport', '2024-02-07'),
('NOT023', 'ALT023', 'D001', 'RESOURCE', 'Heavy rain alert - Take precautions', '2024-02-12'),
('NOT024', 'ALT024', 'D002', 'HR', 'Filter clogged - Maintenance needed', '2024-02-12'),
('NOT025', 'ALT025', 'D003', 'RESOURCE', 'Payment delays - Follow up', '2024-02-12'),
('NOT026', 'ALT026', 'D004', 'HR', 'Interview no-shows - Reschedule', '2024-02-12'),
('NOT027', 'ALT027', 'D001', 'RESOURCE', 'Tractor repair needed urgently', '2024-02-17'),
('NOT028', 'ALT028', 'D002', 'HR', 'Contamination found - Stop production', '2024-02-17'),
('NOT029', 'ALT029', 'D003', 'RESOURCE', 'Order cancellation - Review', '2024-02-17'),
('NOT030', 'ALT030', 'D004', 'HR', 'Tax error - Correct immediately', '2024-02-17'),
('NOT031', 'ALT031', 'D005', 'RESOURCE', 'Box shortage - Order supplies', '2024-02-17'),
('NOT032', 'ALT032', 'D006', 'HR', 'Overstock alert - Reduce inventory', '2024-02-17'),
('NOT033', 'ALT033', 'D001', 'RESOURCE', 'Fertilizer low - Purchase', '2024-03-07'),
('NOT034', 'ALT034', 'D002', 'HR', 'Color variation - Investigate', '2024-03-07'),
('NOT035', 'ALT035', 'D003', 'RESOURCE', 'Low demand season - Plan accordingly', '2024-03-07'),
('NOT036', 'ALT036', 'D004', 'HR', 'Training needed - Schedule session', '2024-03-07'),
('NOT037', 'ALT037', 'D005', 'RESOURCE', 'Sealing issue - Check machine', '2024-03-07'),
('NOT038', 'ALT038', 'D006', 'HR', 'Fuel shortage - Arrange supply', '2024-03-07'),
('NOT039', 'ALT039', 'D001', 'RESOURCE', 'High temperature warning', '2024-03-12'),
('NOT040', 'ALT040', 'D002', 'HR', 'Low honey flow - Investigate', '2024-03-12'),
('NOT041', 'ALT041', 'D003', 'RESOURCE', 'Profit margin low - Review pricing', '2024-03-12'),
('NOT042', 'ALT042', 'D004', 'HR', 'Offer declined - Find alternative', '2024-03-12'),
('NOT043', 'ALT043', 'D001', 'RESOURCE', 'Generator failure - Repair', '2024-03-17'),
('NOT044', 'ALT044', 'D002', 'HR', 'pH level abnormal - Adjust process', '2024-03-17'),
('NOT045', 'ALT045', 'D003', 'RESOURCE', 'Late delivery - Apologize', '2024-03-17'),
('NOT046', 'ALT046', 'D004', 'HR', 'Bank account change - Update records', '2024-03-17'),
('NOT047', 'ALT047', 'D005', 'RESOURCE', 'Lid shortage - Order now', '2024-03-17'),
('NOT048', 'ALT048', 'D006', 'HR', 'Expiry approaching - Sell fast', '2024-03-17'),
('NOT049', 'ALT049', 'D001', 'RESOURCE', 'Q1 targets not met - Improve', '2024-04-07'),
('NOT050', 'ALT050', 'D002', 'HR', 'Quality downgrade - Take action', '2024-04-07'),
('NOT051', 'ALT051', 'D003', 'RESOURCE', 'Sales decline - Boost marketing', '2024-04-07'),
('NOT052', 'ALT052', 'D004', 'HR', 'High turnover - Review policies', '2024-04-07'),
('NOT053', 'ALT053', 'D005', 'RESOURCE', 'Wastage increase - Control', '2024-04-07'),
('NOT054', 'ALT054', 'D006', 'HR', 'Budget overshoot - Cut costs', '2024-04-07'),
('NOT055', 'ALT055', 'D001', 'RESOURCE', 'Storm warning - Secure farm', '2024-04-12'),
('NOT056', 'ALT056', 'D002', 'HR', 'Machine calibration needed', '2024-04-12'),
('NOT057', 'ALT057', 'D003', 'RESOURCE', 'Collection pending - Remind', '2024-04-12'),
('NOT058', 'ALT058', 'D004', 'HR', 'Skill gap - Provide training', '2024-04-12'),
('NOT059', 'ALT059', 'D001', 'RESOURCE', 'Belt replacement needed', '2024-04-17'),
('NOT060', 'ALT060', 'D002', 'HR', 'Bacterial presence - Sanitize', '2024-04-17'),
('NOT061', 'ALT061', 'D003', 'RESOURCE', 'Return request - Process', '2024-04-17'),
('NOT062', 'ALT062', 'D004', 'HR', 'Overtime calculation - Verify', '2024-04-17'),
('NOT063', 'ALT063', 'D005', 'RESOURCE', 'Label shortage - Print more', '2024-04-17'),
('NOT064', 'ALT064', 'D006', 'HR', 'Space constraint - Expand', '2024-04-17'),
('NOT065', 'ALT065', 'D001', 'RESOURCE', 'Seeds low - Purchase', '2024-05-07'),
('NOT066', 'ALT066', 'D002', 'HR', 'Adulteration suspected - Test', '2024-05-07'),
('NOT067', 'ALT067', 'D003', 'RESOURCE', 'Price competition - Adjust', '2024-05-07'),
('NOT068', 'ALT068', 'D004', 'HR', 'Complaint filed - Investigate', '2024-05-07'),
('NOT069', 'ALT069', 'D005', 'RESOURCE', 'Weight variation - Calibrate', '2024-05-07'),
('NOT070', 'ALT070', 'D006', 'HR', 'Electricity outage - Use backup', '2024-05-07');

-- =========================
-- 70 RECORDS FOR VACANCY
-- =========================
INSERT INTO vacancy (vacancy_id, department_id, role_id, notification_id, created_by_employee_id, vacancy_status, description, created_date) VALUES
('VAC001', 'D001', 'R007', 'NOT001', 'EMP001', 'Open', 'Hive Technician needed for farm operations', '2024-01-01'),
('VAC002', 'D002', 'R008', 'NOT002', 'EMP002', 'Open', 'Extraction Operator required', '2024-01-02'),
('VAC003', 'D003', 'R011', 'NOT003', 'EMP003', 'Open', 'Sales Executive position available', '2024-01-03'),
('VAC004', 'D004', 'R013', 'NOT004', 'EMP004', 'Closed', 'Recruitment Officer needed', '2024-01-04'),
('VAC005', 'D005', 'R009', 'NOT005', 'EMP005', 'Open', 'Packing Supervisor required', '2024-01-05'),
('VAC006', 'D006', 'R015', 'NOT006', 'EMP006', 'Open', 'Resource Manager position', '2024-01-06'),
('VAC007', 'D001', 'R004', 'NOT007', 'EMP007', 'Open', 'Farm worker needed', '2024-01-07'),
('VAC008', 'D002', 'R006', 'NOT008', 'EMP008', 'Closed', 'Quality Control Specialist', '2024-01-08'),
('VAC009', 'D003', 'R018', 'NOT009', 'EMP009', 'Open', 'Accountant required', '2024-01-09'),
('VAC010', 'D004', 'R014', 'NOT010', 'EMP016', 'Open', 'Payroll Officer position', '2024-01-10'),
('VAC011', 'D001', 'R020', 'NOT011', 'EMP010', 'Open', 'General Worker needed', '2024-01-11'),
('VAC012', 'D002', 'R017', 'NOT012', 'EMP012', 'Closed', 'Lab Technician required', '2024-01-12'),
('VAC013', 'D003', 'R011', 'NOT013', 'EMP014', 'Open', 'Sales Executive needed', '2024-01-13'),
('VAC014', 'D004', 'R013', 'NOT014', 'EMP017', 'Open', 'Recruitment Officer', '2024-01-14'),
('VAC015', 'D005', 'R020', 'NOT015', 'EMP018', 'Closed', 'Packing worker needed', '2024-01-15'),
('VAC016', 'D006', 'R016', 'NOT016', 'EMP020', 'Open', 'Warehouse Keeper required', '2024-01-16'),
('VAC017', 'D001', 'R007', 'NOT017', 'EMP001', 'Open', 'Senior Hive Technician', '2024-02-01'),
('VAC018', 'D002', 'R008', 'NOT018', 'EMP002', 'Open', 'Senior Extraction Operator', '2024-02-02'),
('VAC019', 'D003', 'R010', 'NOT019', 'EMP003', 'Closed', 'Sales Manager needed', '2024-02-03'),
('VAC020', 'D004', 'R012', 'NOT020', 'EMP004', 'Open', 'HR Manager position', '2024-02-04'),
('VAC021', 'D005', 'R009', 'NOT021', 'EMP005', 'Open', 'Packing Manager needed', '2024-02-05'),
('VAC022', 'D006', 'R015', 'NOT022', 'EMP006', 'Open', 'Senior Resource Manager', '2024-02-06'),
('VAC023', 'D001', 'R004', 'NOT023', 'EMP007', 'Closed', 'Farm Supervisor needed', '2024-02-07'),
('VAC024', 'D002', 'R006', 'NOT024', 'EMP008', 'Open', 'Senior QC Specialist', '2024-02-08'),
('VAC025', 'D003', 'R018', 'NOT025', 'EMP009', 'Open', 'Senior Accountant', '2024-02-09'),
('VAC026', 'D004', 'R014', 'NOT026', 'EMP016', 'Open', 'Senior Payroll Officer', '2024-02-10'),
('VAC027', 'D001', 'R020', 'NOT027', 'EMP010', 'Open', 'Farm Laborer needed', '2024-02-11'),
('VAC028', 'D002', 'R017', 'NOT028', 'EMP012', 'Closed', 'Senior Lab Technician', '2024-02-12'),
('VAC029', 'D003', 'R011', 'NOT029', 'EMP014', 'Open', 'Inside Sales Executive', '2024-02-13'),
('VAC030', 'D004', 'R013', 'NOT030', 'EMP017', 'Open', 'Talent Acquisition Specialist', '2024-02-14'),
('VAC031', 'D005', 'R020', 'NOT031', 'EMP018', 'Open', 'Packing Associate needed', '2024-02-15'),
('VAC032', 'D006', 'R016', 'NOT032', 'EMP020', 'Closed', 'Inventory Controller', '2024-02-16'),
('VAC033', 'D001', 'R002', 'NOT033', 'EMP025', 'Open', 'Farm Department Manager', '2024-03-01'),
('VAC034', 'D002', 'R002', 'NOT034', 'EMP027', 'Open', 'Processing Department Manager', '2024-03-02'),
('VAC035', 'D003', 'R002', 'NOT035', 'EMP029', 'Open', 'Sales Department Manager', '2024-03-03'),
('VAC036', 'D004', 'R002', 'NOT036', 'EMP030', 'Closed', 'HR Department Manager', '2024-03-04'),
('VAC037', 'D005', 'R002', 'NOT037', 'EMP032', 'Open', 'Packing Department Manager', '2024-03-05'),
('VAC038', 'D006', 'R002', 'NOT038', 'EMP034', 'Open', 'Resource Department Manager', '2024-03-06'),
('VAC039', 'D001', 'R003', 'NOT039', 'EMP036', 'Open', 'Senior Farm Supervisor', '2024-03-07'),
('VAC040', 'D002', 'R003', 'NOT040', 'EMP038', 'Open', 'Senior Processing Supervisor', '2024-03-08'),
('VAC041', 'D003', 'R003', 'NOT041', 'EMP039', 'Open', 'Senior Sales Supervisor', '2024-03-09'),
('VAC042', 'D004', 'R003', 'NOT042', 'EMP040', 'Closed', 'Senior HR Supervisor', '2024-03-10'),
('VAC043', 'D005', 'R003', 'NOT043', 'EMP041', 'Open', 'Senior Packing Supervisor', '2024-03-11'),
('VAC044', 'D006', 'R003', 'NOT044', 'EMP042', 'Open', 'Senior Resource Supervisor', '2024-03-12'),
('VAC045', 'D001', 'R005', 'NOT045', 'EMP043', 'Open', 'Honey Processing Manager', '2024-03-13'),
('VAC046', 'D002', 'R007', 'NOT046', 'EMP044', 'Open', 'Junior Hive Technician', '2024-03-14'),
('VAC047', 'D003', 'R011', 'NOT047', 'EMP045', 'Closed', 'Field Sales Executive', '2024-03-15'),
('VAC048', 'D004', 'R013', 'NOT048', 'EMP046', 'Open', 'HR Assistant needed', '2024-03-16'),
('VAC049', 'D001', 'R020', 'NOT049', 'EMP047', 'Open', 'Farm Helper needed', '2024-04-01'),
('VAC050', 'D002', 'R008', 'NOT050', 'EMP048', 'Open', 'Machine Operator required', '2024-04-02'),
('VAC051', 'D003', 'R018', 'NOT051', 'EMP049', 'Open', 'Junior Accountant', '2024-04-03'),
('VAC052', 'D004', 'R014', 'NOT052', 'EMP050', 'Closed', 'HR Coordinator needed', '2024-04-04'),
('VAC053', 'D005', 'R009', 'NOT053', 'EMP051', 'Open', 'Packing Coordinator', '2024-04-05'),
('VAC054', 'D006', 'R016', 'NOT054', 'EMP052', 'Open', 'Store Keeper needed', '2024-04-06'),
('VAC055', 'D001', 'R007', 'NOT055', 'EMP001', 'Open', 'Hive Inspector needed', '2024-04-07'),
('VAC056', 'D002', 'R006', 'NOT056', 'EMP002', 'Open', 'Quality Analyst required', '2024-04-08'),
('VAC057', 'D003', 'R011', 'NOT057', 'EMP003', 'Open', 'Corporate Sales Executive', '2024-04-09'),
('VAC058', 'D004', 'R013', 'NOT058', 'EMP004', 'Closed', 'Recruitment Specialist', '2024-04-10'),
('VAC059', 'D005', 'R020', 'NOT059', 'EMP005', 'Open', 'Packing Helper needed', '2024-04-11'),
('VAC060', 'D006', 'R015', 'NOT060', 'EMP006', 'Open', 'Resource Coordinator', '2024-04-12'),
('VAC061', 'D001', 'R004', 'NOT061', 'EMP007', 'Open', 'Farm Technician needed', '2024-04-13'),
('VAC062', 'D002', 'R017', 'NOT062', 'EMP008', 'Open', 'Lab Assistant required', '2024-04-14'),
('VAC063', 'D003', 'R011', 'NOT063', 'EMP009', 'Closed', 'Retail Sales Executive', '2024-04-15'),
('VAC064', 'D004', 'R014', 'NOT064', 'EMP016', 'Open', 'Payroll Assistant', '2024-04-16'),
('VAC065', 'D001', 'R020', 'NOT065', 'EMP010', 'Open', 'Farm Assistant needed', '2024-05-01'),
('VAC066', 'D002', 'R008', 'NOT066', 'EMP012', 'Open', 'Extraction Assistant', '2024-05-02'),
('VAC067', 'D003', 'R018', 'NOT067', 'EMP014', 'Open', 'Accounts Assistant', '2024-05-03'),
('VAC068', 'D004', 'R013', 'NOT068', 'EMP017', 'Closed', 'HR Intern needed', '2024-05-04'),
('VAC069', 'D005', 'R009', 'NOT069', 'EMP018', 'Open', 'Packing Supervisor Trainee', '2024-05-05'),
('VAC070', 'D006', 'R016', 'NOT070', 'EMP020', 'Open', 'Warehouse Assistant', '2024-05-06');

-- =========================
-- 70 RECORDS FOR APPLICATION
-- =========================
INSERT INTO application (candidate_id, vacancy_id, apply_date, application_status) VALUES
('CAN001', 'VAC001', '2024-01-05', 'Pending'), ('CAN002', 'VAC002', '2024-01-06', 'Approved'), ('CAN003', 'VAC003', '2024-01-07', 'Rejected'),
('CAN004', 'VAC004', '2024-01-08', 'Pending'), ('CAN005', 'VAC005', '2024-01-09', 'Approved'), ('CAN006', 'VAC006', '2024-01-10', 'Pending'),
('CAN007', 'VAC007', '2024-01-11', 'Rejected'), ('CAN008', 'VAC008', '2024-01-12', 'Approved'), ('CAN009', 'VAC009', '2024-01-13', 'Pending'),
('CAN010', 'VAC010', '2024-01-14', 'Approved'), ('CAN011', 'VAC011', '2024-01-15', 'Pending'), ('CAN012', 'VAC012', '2024-01-16', 'Rejected'),
('CAN013', 'VAC013', '2024-01-17', 'Approved'), ('CAN014', 'VAC014', '2024-01-18', 'Pending'), ('CAN015', 'VAC015', '2024-01-19', 'Approved'),
('CAN016', 'VAC016', '2024-01-20', 'Pending'), ('CAN017', 'VAC017', '2024-02-05', 'Rejected'), ('CAN018', 'VAC018', '2024-02-06', 'Approved'),
('CAN019', 'VAC019', '2024-02-07', 'Pending'), ('CAN020', 'VAC020', '2024-02-08', 'Approved'), ('CAN021', 'VAC021', '2024-02-09', 'Pending'),
('CAN022', 'VAC022', '2024-02-10', 'Rejected'), ('CAN023', 'VAC023', '2024-02-11', 'Approved'), ('CAN024', 'VAC024', '2024-02-12', 'Pending'),
('CAN025', 'VAC025', '2024-02-13', 'Approved'), ('CAN026', 'VAC026', '2024-02-14', 'Pending'), ('CAN027', 'VAC027', '2024-02-15', 'Rejected'),
('CAN028', 'VAC028', '2024-02-16', 'Approved'), ('CAN029', 'VAC029', '2024-02-17', 'Pending'), ('CAN030', 'VAC030', '2024-02-18', 'Approved'),
('CAN031', 'VAC031', '2024-02-19', 'Pending'), ('CAN032', 'VAC032', '2024-02-20', 'Rejected'), ('CAN033', 'VAC033', '2024-03-05', 'Approved'),
('CAN034', 'VAC034', '2024-03-06', 'Pending'), ('CAN035', 'VAC035', '2024-03-07', 'Approved'), ('CAN036', 'VAC036', '2024-03-08', 'Pending'),
('CAN037', 'VAC037', '2024-03-09', 'Rejected'), ('CAN038', 'VAC038', '2024-03-10', 'Approved'), ('CAN039', 'VAC039', '2024-03-11', 'Pending'),
('CAN040', 'VAC040', '2024-03-12', 'Approved'), ('CAN041', 'VAC041', '2024-03-13', 'Pending'), ('CAN042', 'VAC042', '2024-03-14', 'Rejected'),
('CAN043', 'VAC043', '2024-03-15', 'Approved'), ('CAN044', 'VAC044', '2024-03-16', 'Pending'), ('CAN045', 'VAC045', '2024-03-17', 'Approved'),
('CAN046', 'VAC046', '2024-03-18', 'Pending'), ('CAN047', 'VAC047', '2024-03-19', 'Rejected'), ('CAN048', 'VAC048', '2024-03-20', 'Approved'),
('CAN049', 'VAC049', '2024-04-05', 'Pending'), ('CAN050', 'VAC050', '2024-04-06', 'Approved'), ('CAN051', 'VAC051', '2024-04-07', 'Pending'),
('CAN052', 'VAC052', '2024-04-08', 'Rejected'), ('CAN053', 'VAC053', '2024-04-09', 'Approved'), ('CAN054', 'VAC054', '2024-04-10', 'Pending'),
('CAN055', 'VAC055', '2024-04-11', 'Approved'), ('CAN056', 'VAC056', '2024-04-12', 'Pending'), ('CAN057', 'VAC057', '2024-04-13', 'Rejected'),
('CAN058', 'VAC058', '2024-04-14', 'Approved'), ('CAN059', 'VAC059', '2024-04-15', 'Pending'), ('CAN060', 'VAC060', '2024-04-16', 'Approved'),
('CAN061', 'VAC061', '2024-04-17', 'Pending'), ('CAN062', 'VAC062', '2024-04-18', 'Rejected'), ('CAN063', 'VAC063', '2024-04-19', 'Approved'),
('CAN064', 'VAC064', '2024-04-20', 'Pending'), ('CAN065', 'VAC065', '2024-05-05', 'Approved'), ('CAN066', 'VAC066', '2024-05-06', 'Pending'),
('CAN067', 'VAC067', '2024-05-07', 'Rejected'), ('CAN068', 'VAC068', '2024-05-08', 'Approved'), ('CAN069', 'VAC069', '2024-05-09', 'Pending'),
('CAN070', 'VAC070', '2024-05-10', 'Approved');

-- =========================
-- 70 RECORDS FOR ASSIGNMENT
-- =========================
INSERT INTO assignment (candidate_id, vacancy_id, employee_id, department_id, role_id, joining_date) VALUES
('CAN001', 'VAC001', 'EMP001', 'D001', 'R007', '2024-01-20'), ('CAN002', 'VAC002', 'EMP002', 'D002', 'R008', '2024-01-21'),
('CAN005', 'VAC005', 'EMP005', 'D005', 'R009', '2024-01-24'), ('CAN008', 'VAC008', 'EMP008', 'D002', 'R006', '2024-01-27'),
('CAN010', 'VAC010', 'EMP016', 'D004', 'R014', '2024-01-29'), ('CAN013', 'VAC013', 'EMP014', 'D003', 'R011', '2024-02-01'),
('CAN018', 'VAC018', 'EMP008', 'D002', 'R008', '2024-02-21'), ('CAN020', 'VAC020', 'EMP004', 'D004', 'R012', '2024-02-23'),
('CAN023', 'VAC023', 'EMP007', 'D001', 'R004', '2024-02-26'), ('CAN025', 'VAC025', 'EMP009', 'D003', 'R018', '2024-02-28'),
('CAN028', 'VAC028', 'EMP012', 'D002', 'R017', '2024-03-01'), ('CAN030', 'VAC030', 'EMP017', 'D004', 'R013', '2024-03-03'),
('CAN033', 'VAC033', 'EMP001', 'D001', 'R002', '2024-03-20'), ('CAN035', 'VAC035', 'EMP003', 'D003', 'R002', '2024-03-22'),
('CAN038', 'VAC038', 'EMP006', 'D006', 'R002', '2024-03-25'), ('CAN040', 'VAC040', 'EMP038', 'D002', 'R003', '2024-03-27'),
('CAN043', 'VAC043', 'EMP041', 'D005', 'R003', '2024-03-30'), ('CAN045', 'VAC045', 'EMP043', 'D001', 'R005', '2024-04-01'),
('CAN048', 'VAC048', 'EMP046', 'D004', 'R013', '2024-04-03'), ('CAN050', 'VAC050', 'EMP048', 'D002', 'R008', '2024-04-21'),
('CAN053', 'VAC053', 'EMP051', 'D005', 'R009', '2024-04-24'), ('CAN055', 'VAC055', 'EMP001', 'D001', 'R007', '2024-04-26'),
('CAN058', 'VAC058', 'EMP004', 'D004', 'R013', '2024-04-29'), ('CAN060', 'VAC060', 'EMP006', 'D006', 'R015', '2024-05-01'),
('CAN063', 'VAC063', 'EMP009', 'D003', 'R011', '2024-05-04'), ('CAN065', 'VAC065', 'EMP010', 'D001', 'R020', '2024-05-20'),
('CAN068', 'VAC068', 'EMP004', 'D004', 'R013', '2024-05-23'), ('CAN070', 'VAC070', 'EMP020', 'D006', 'R016', '2024-05-25');

-- =========================
-- 70 RECORDS FOR RESOURCE_REQUEST
-- =========================
INSERT INTO resource_request (request_id, department_id, alert_id, request_date, request_status) VALUES
('REQ001', 'D001', 'ALT001', '2024-01-06', 'Approved'), ('REQ002', 'D002', 'ALT002', '2024-01-06', 'Pending'),
('REQ003', 'D003', 'ALT003', '2024-01-06', 'Approved'), ('REQ004', 'D004', 'ALT004', '2024-01-06', 'Rejected'),
('REQ005', 'D005', 'ALT005', '2024-01-06', 'Approved'), ('REQ006', 'D006', 'ALT006', '2024-01-06', 'Pending'),
('REQ007', 'D001', 'ALT007', '2024-01-11', 'Approved'), ('REQ008', 'D002', 'ALT008', '2024-01-11', 'Approved'),
('REQ009', 'D003', 'ALT009', '2024-01-11', 'Pending'), ('REQ010', 'D004', 'ALT010', '2024-01-11', 'Approved'),
('REQ011', 'D001', 'ALT011', '2024-01-16', 'Approved'), ('REQ012', 'D002', 'ALT012', '2024-01-16', 'Rejected'),
('REQ013', 'D003', 'ALT013', '2024-01-16', 'Pending'), ('REQ014', 'D004', 'ALT014', '2024-01-16', 'Approved'),
('REQ015', 'D005', 'ALT015', '2024-01-16', 'Approved'), ('REQ016', 'D006', 'ALT016', '2024-01-16', 'Pending'),
('REQ017', 'D001', 'ALT017', '2024-02-06', 'Approved'), ('REQ018', 'D002', 'ALT018', '2024-02-06', 'Approved'),
('REQ019', 'D003', 'ALT019', '2024-02-06', 'Pending'), ('REQ020', 'D004', 'ALT020', '2024-02-06', 'Approved'),
('REQ021', 'D005', 'ALT021', '2024-02-06', 'Rejected'), ('REQ022', 'D006', 'ALT022', '2024-02-06', 'Approved'),
('REQ023', 'D001', 'ALT023', '2024-02-11', 'Pending'), ('REQ024', 'D002', 'ALT024', '2024-02-11', 'Approved'),
('REQ025', 'D003', 'ALT025', '2024-02-11', 'Approved'), ('REQ026', 'D004', 'ALT026', '2024-02-11', 'Pending'),
('REQ027', 'D001', 'ALT027', '2024-02-16', 'Approved'), ('REQ028', 'D002', 'ALT028', '2024-02-16', 'Rejected'),
('REQ029', 'D003', 'ALT029', '2024-02-16', 'Approved'), ('REQ030', 'D004', 'ALT030', '2024-02-16', 'Pending'),
('REQ031', 'D005', 'ALT031', '2024-02-16', 'Approved'), ('REQ032', 'D006', 'ALT032', '2024-02-16', 'Approved'),
('REQ033', 'D001', 'ALT033', '2024-03-06', 'Pending'), ('REQ034', 'D002', 'ALT034', '2024-03-06', 'Approved'),
('REQ035', 'D003', 'ALT035', '2024-03-06', 'Approved'), ('REQ036', 'D004', 'ALT036', '2024-03-06', 'Rejected'),
('REQ037', 'D005', 'ALT037', '2024-03-06', 'Pending'), ('REQ038', 'D006', 'ALT038', '2024-03-06', 'Approved'),
('REQ039', 'D001', 'ALT039', '2024-03-11', 'Approved'), ('REQ040', 'D002', 'ALT040', '2024-03-11', 'Pending'),
('REQ041', 'D003', 'ALT041', '2024-03-11', 'Approved'), ('REQ042', 'D004', 'ALT042', '2024-03-11', 'Approved'),
('REQ043', 'D001', 'ALT043', '2024-03-16', 'Pending'), ('REQ044', 'D002', 'ALT044', '2024-03-16', 'Approved'),
('REQ045', 'D003', 'ALT045', '2024-03-16', 'Rejected'), ('REQ046', 'D004', 'ALT046', '2024-03-16', 'Approved'),
('REQ047', 'D005', 'ALT047', '2024-03-16', 'Pending'), ('REQ048', 'D006', 'ALT048', '2024-03-16', 'Approved'),
('REQ049', 'D001', 'ALT049', '2024-04-06', 'Approved'), ('REQ050', 'D002', 'ALT050', '2024-04-06', 'Pending'),
('REQ051', 'D003', 'ALT051', '2024-04-06', 'Approved'), ('REQ052', 'D004', 'ALT052', '2024-04-06', 'Approved'),
('REQ053', 'D005', 'ALT053', '2024-04-06', 'Rejected'), ('REQ054', 'D006', 'ALT054', '2024-04-06', 'Pending'),
('REQ055', 'D001', 'ALT055', '2024-04-11', 'Approved'), ('REQ056', 'D002', 'ALT056', '2024-04-11', 'Approved'),
('REQ057', 'D003', 'ALT057', '2024-04-11', 'Pending'), ('REQ058', 'D004', 'ALT058', '2024-04-11', 'Approved'),
('REQ059', 'D001', 'ALT059', '2024-04-16', 'Approved'), ('REQ060', 'D002', 'ALT060', '2024-04-16', 'Rejected'),
('REQ061', 'D003', 'ALT061', '2024-04-16', 'Pending'), ('REQ062', 'D004', 'ALT062', '2024-04-16', 'Approved'),
('REQ063', 'D005', 'ALT063', '2024-04-16', 'Approved'), ('REQ064', 'D006', 'ALT064', '2024-04-16', 'Pending'),
('REQ065', 'D001', 'ALT065', '2024-05-06', 'Approved'), ('REQ066', 'D002', 'ALT066', '2024-05-06', 'Approved'),
('REQ067', 'D003', 'ALT067', '2024-05-06', 'Pending'), ('REQ068', 'D004', 'ALT068', '2024-05-06', 'Approved'),
('REQ069', 'D005', 'ALT069', '2024-05-06', 'Rejected'), ('REQ070', 'D006', 'ALT070', '2024-05-06', 'Approved');

-- =========================
-- 70 RECORDS FOR REQUEST_DETAIL
-- =========================
INSERT INTO request_detail (request_id, resource_id, quantity) VALUES
('REQ001', 'RES001', 10), ('REQ001', 'RES002', 20), ('REQ002', 'RES003', 2), ('REQ003', 'RES004', 5),
('REQ003', 'RES005', 3), ('REQ004', 'RES006', 1), ('REQ005', 'RES007', 15), ('REQ006', 'RES008', 8),
('REQ007', 'RES009', 4), ('REQ008', 'RES010', 2), ('REQ009', 'RES011', 3), ('REQ010', 'RES012', 5),
('REQ011', 'RES013', 10), ('REQ012', 'RES014', 20), ('REQ013', 'RES015', 5), ('REQ014', 'RES016', 15),
('REQ015', 'RES017', 2), ('REQ016', 'RES018', 4), ('REQ017', 'RES019', 30), ('REQ018', 'RES020', 50),
('REQ019', 'RES021', 5), ('REQ020', 'RES022', 10), ('REQ021', 'RES023', 8), ('REQ022', 'RES024', 6),
('REQ023', 'RES025', 4), ('REQ024', 'RES001', 12), ('REQ025', 'RES002', 18), ('REQ026', 'RES003', 3),
('REQ027', 'RES004', 6), ('REQ028', 'RES005', 4), ('REQ029', 'RES006', 2), ('REQ030', 'RES007', 20),
('REQ031', 'RES008', 10), ('REQ032', 'RES009', 5), ('REQ033', 'RES010', 3), ('REQ034', 'RES011', 4),
('REQ035', 'RES012', 6), ('REQ036', 'RES013', 15), ('REQ037', 'RES014', 25), ('REQ038', 'RES015', 8),
('REQ039', 'RES016', 12), ('REQ040', 'RES017', 3), ('REQ041', 'RES018', 5), ('REQ042', 'RES019', 40),
('REQ043', 'RES020', 60), ('REQ044', 'RES021', 6), ('REQ045', 'RES022', 12), ('REQ046', 'RES023', 10),
('REQ047', 'RES024', 8), ('REQ048', 'RES025', 5), ('REQ049', 'RES001', 15), ('REQ050', 'RES002', 22),
('REQ051', 'RES003', 4), ('REQ052', 'RES004', 8), ('REQ053', 'RES005', 6), ('REQ054', 'RES006', 3),
('REQ055', 'RES007', 18), ('REQ056', 'RES008', 12), ('REQ057', 'RES009', 6), ('REQ058', 'RES010', 4),
('REQ059', 'RES011', 5), ('REQ060', 'RES012', 7), ('REQ061', 'RES013', 20), ('REQ062', 'RES014', 30),
('REQ063', 'RES015', 10), ('REQ064', 'RES016', 15), ('REQ065', 'RES017', 4), ('REQ066', 'RES018', 6),
('REQ067', 'RES019', 50), ('REQ068', 'RES020', 70), ('REQ069', 'RES021', 8), ('REQ070', 'RES022', 15);

-- =========================
-- 70 RECORDS FOR RESOURCE_ALLOCATION
-- =========================
INSERT INTO resource_allocation (request_id, resource_id, department_id, allocated_quantity, allocation_date) VALUES
('REQ001', 'RES001', 'D001', 10, '2024-01-07'), ('REQ001', 'RES002', 'D001', 20, '2024-01-07'),
('REQ003', 'RES004', 'D003', 5, '2024-01-08'), ('REQ003', 'RES005', 'D003', 3, '2024-01-08'),
('REQ005', 'RES007', 'D005', 15, '2024-01-09'), ('REQ007', 'RES009', 'D001', 4, '2024-01-12'),
('REQ008', 'RES010', 'D002', 2, '2024-01-12'), ('REQ010', 'RES012', 'D004', 5, '2024-01-13'),
('REQ011', 'RES013', 'D001', 10, '2024-01-18'), ('REQ014', 'RES016', 'D004', 15, '2024-01-18'),
('REQ015', 'RES017', 'D005', 2, '2024-01-19'), ('REQ017', 'RES019', 'D001', 30, '2024-02-07'),
('REQ018', 'RES020', 'D002', 50, '2024-02-07'), ('REQ020', 'RES022', 'D004', 10, '2024-02-09'),
('REQ022', 'RES024', 'D006', 6, '2024-02-10'), ('REQ024', 'RES001', 'D002', 12, '2024-02-13'),
('REQ025', 'RES002', 'D003', 18, '2024-02-13'), ('REQ027', 'RES004', 'D001', 6, '2024-02-18'),
('REQ029', 'RES006', 'D003', 2, '2024-02-18'), ('REQ031', 'RES008', 'D005', 10, '2024-02-19'),
('REQ032', 'RES009', 'D006', 5, '2024-02-19'), ('REQ034', 'RES011', 'D002', 4, '2024-03-07'),
('REQ035', 'RES012', 'D003', 6, '2024-03-07'), ('REQ038', 'RES015', 'D006', 8, '2024-03-09'),
('REQ039', 'RES016', 'D001', 12, '2024-03-12'), ('REQ041', 'RES018', 'D003', 5, '2024-03-13'),
('REQ042', 'RES019', 'D004', 40, '2024-03-13'), ('REQ044', 'RES021', 'D002', 6, '2024-03-18'),
('REQ046', 'RES023', 'D004', 10, '2024-03-19'), ('REQ048', 'RES025', 'D006', 5, '2024-03-20'),
('REQ049', 'RES001', 'D001', 15, '2024-04-07'), ('REQ051', 'RES003', 'D003', 4, '2024-04-08'),
('REQ052', 'RES004', 'D004', 8, '2024-04-08'), ('REQ055', 'RES007', 'D001', 18, '2024-04-12'),
('REQ056', 'RES008', 'D002', 12, '2024-04-12'), ('REQ058', 'RES010', 'D004', 4, '2024-04-14'),
('REQ059', 'RES011', 'D001', 5, '2024-04-18'), ('REQ062', 'RES014', 'D004', 30, '2024-04-19'),
('REQ063', 'RES015', 'D005', 10, '2024-04-19'), ('REQ065', 'RES017', 'D001', 4, '2024-05-07'),
('REQ066', 'RES018', 'D002', 6, '2024-05-07'), ('REQ068', 'RES020', 'D004', 70, '2024-05-09'),
('REQ070', 'RES022', 'D006', 15, '2024-05-10');

-- =========================
-- 70 RECORDS FOR TEST_REPORT
-- =========================
INSERT INTO test_report (test_report_id, batch_id, report_id, purity, category, test_date) VALUES
('TR001', 'B001', 'RPT002', 98.5, 'Grade A', '2024-01-16'),
('TR002', 'B002', 'RPT002', 97.2, 'Grade A', '2024-01-21'),
('TR003', 'B003', 'RPT002', 96.8, 'Grade B', '2024-01-26'),
('TR004', 'B004', 'RPT012', 99.1, 'Grade A', '2024-02-02'),
('TR005', 'B005', 'RPT012', 95.5, 'Grade B', '2024-02-06'),
('TR006', 'B006', 'RPT012', 98.9, 'Grade A', '2024-02-11'),
('TR007', 'B007', 'RPT018', 97.5, 'Grade A', '2024-02-16'),
('TR008', 'B008', 'RPT018', 96.2, 'Grade B', '2024-02-21'),
('TR009', 'B009', 'RPT018', 99.3, 'Grade A', '2024-02-26'),
('TR010', 'B010', 'RPT028', 94.8, 'Grade B', '2024-03-02'),
('TR011', 'B011', 'RPT028', 98.7, 'Grade A', '2024-03-06'),
('TR012', 'B012', 'RPT028', 97.9, 'Grade A', '2024-03-11'),
('TR013', 'B013', 'RPT034', 96.5, 'Grade B', '2024-03-16'),
('TR014', 'B014', 'RPT034', 99.2, 'Grade A', '2024-03-21'),
('TR015', 'B015', 'RPT034', 95.8, 'Grade B', '2024-03-26'),
('TR016', 'B016', 'RPT044', 98.4, 'Grade A', '2024-04-02'),
('TR017', 'B017', 'RPT044', 97.1, 'Grade A', '2024-04-06'),
('TR018', 'B018', 'RPT044', 96.7, 'Grade B', '2024-04-11'),
('TR019', 'B019', 'RPT050', 99.5, 'Grade A', '2024-04-16'),
('TR020', 'B020', 'RPT050', 95.2, 'Grade B', '2024-04-21'),
('TR021', 'B021', 'RPT050', 98.8, 'Grade A', '2024-04-26'),
('TR022', 'B022', 'RPT060', 97.4, 'Grade A', '2024-05-02'),
('TR023', 'B023', 'RPT060', 96.9, 'Grade B', '2024-05-06'),
('TR024', 'B024', 'RPT060', 99.0, 'Grade A', '2024-05-11'),
('TR025', 'B025', 'RPT066', 98.3, 'Grade A', '2024-05-16'),
('TR026', 'B026', 'RPT066', 97.8, 'Grade A', '2024-05-21'),
('TR027', 'B027', 'RPT066', 95.9, 'Grade B', '2024-05-26'),
('TR028', 'B028', 'RPT002', 99.4, 'Grade A', '2024-06-02'),
('TR029', 'B029', 'RPT012', 98.1, 'Grade A', '2024-06-06'),
('TR030', 'B030', 'RPT018', 96.4, 'Grade B', '2024-06-11'),
('TR031', 'B031', 'RPT028', 97.6, 'Grade A', '2024-06-16'),
('TR032', 'B032', 'RPT034', 99.8, 'Grade A', '2024-06-21'),
('TR033', 'B033', 'RPT044', 95.7, 'Grade B', '2024-06-26'),
('TR034', 'B034', 'RPT050', 98.2, 'Grade A', '2024-07-02'),
('TR035', 'B035', 'RPT060', 97.3, 'Grade A', '2024-07-06'),
('TR036', 'B036', 'RPT066', 96.1, 'Grade B', '2024-07-11'),
('TR037', 'B037', 'RPT002', 99.6, 'Grade A', '2024-07-16'),
('TR038', 'B038', 'RPT012', 98.6, 'Grade A', '2024-07-21'),
('TR039', 'B039', 'RPT018', 95.4, 'Grade B', '2024-07-26'),
('TR040', 'B040', 'RPT028', 97.7, 'Grade A', '2024-08-02'),
('TR041', 'B041', 'RPT034', 99.9, 'Grade A', '2024-08-06'),
('TR042', 'B042', 'RPT044', 96.3, 'Grade B', '2024-08-11'),
('TR043', 'B043', 'RPT050', 98.0, 'Grade A', '2024-08-16'),
('TR044', 'B044', 'RPT060', 97.2, 'Grade A', '2024-08-21'),
('TR045', 'B045', 'RPT066', 95.6, 'Grade B', '2024-08-26'),
('TR046', 'B046', 'RPT002', 99.7, 'Grade A', '2024-09-02'),
('TR047', 'B047', 'RPT012', 98.4, 'Grade A', '2024-09-06'),
('TR048', 'B048', 'RPT018', 96.6, 'Grade B', '2024-09-11'),
('TR049', 'B049', 'RPT028', 97.9, 'Grade A', '2024-09-16'),
('TR050', 'B050', 'RPT034', 99.1, 'Grade A', '2024-09-21'),
('TR051', 'B051', 'RPT044', 95.5, 'Grade B', '2024-09-26'),
('TR052', 'B052', 'RPT050', 98.8, 'Grade A', '2024-10-02'),
('TR053', 'B053', 'RPT060', 97.4, 'Grade A', '2024-10-06'),
('TR054', 'B054', 'RPT066', 96.2, 'Grade B', '2024-10-11'),
('TR055', 'B055', 'RPT002', 99.3, 'Grade A', '2024-10-16'),
('TR056', 'B056', 'RPT012', 98.5, 'Grade A', '2024-10-21'),
('TR057', 'B057', 'RPT018', 95.9, 'Grade B', '2024-10-26'),
('TR058', 'B058', 'RPT028', 97.8, 'Grade A', '2024-11-02'),
('TR059', 'B059', 'RPT034', 99.0, 'Grade A', '2024-11-06'),
('TR060', 'B060', 'RPT044', 96.7, 'Grade B', '2024-11-11'),
('TR061', 'B061', 'RPT050', 98.3, 'Grade A', '2024-11-16'),
('TR062', 'B062', 'RPT060', 97.5, 'Grade A', '2024-11-21'),
('TR063', 'B063', 'RPT066', 95.8, 'Grade B', '2024-11-26'),
('TR064', 'B064', 'RPT002', 99.2, 'Grade A', '2024-12-02'),
('TR065', 'B065', 'RPT012', 98.7, 'Grade A', '2024-12-06'),
('TR066', 'B066', 'RPT018', 96.9, 'Grade B', '2024-12-11'),
('TR067', 'B067', 'RPT028', 97.6, 'Grade A', '2024-12-16'),
('TR068', 'B068', 'RPT034', 99.4, 'Grade A', '2024-12-21'),
('TR069', 'B069', 'RPT044', 95.7, 'Grade B', '2024-12-26'),
('TR070', 'B070', 'RPT050', 98.9, 'Grade A', '2024-12-31');

-- =========================
-- 70 RECORDS FOR STORAGE
-- =========================
INSERT INTO storage (batch_id, warehouse_id, quantity, storage_date) VALUES
('B001', 'WH001', 150.50, '2024-01-16'), ('B002', 'WH002', 200.75, '2024-01-21'), ('B003', 'WH003', 175.25, '2024-01-26'),
('B004', 'WH004', 120.00, '2024-02-02'), ('B005', 'WH005', 250.50, '2024-02-06'), ('B006', 'WH006', 180.30, '2024-02-11'),
('B007', 'WH007', 210.80, '2024-02-16'), ('B008', 'WH008', 195.40, '2024-02-21'), ('B009', 'WH009', 165.90, '2024-02-26'),
('B010', 'WH010', 225.60, '2024-03-02'), ('B011', 'WH011', 140.20, '2024-03-06'), ('B012', 'WH012', 190.70, '2024-03-11'),
('B013', 'WH013', 230.40, '2024-03-16'), ('B014', 'WH014', 185.50, '2024-03-21'), ('B015', 'WH015', 205.80, '2024-03-26'),
('B016', 'WH016', 170.30, '2024-04-02'), ('B017', 'WH017', 245.90, '2024-04-06'), ('B018', 'WH018', 160.60, '2024-04-11'),
('B019', 'WH019', 215.40, '2024-04-16'), ('B020', 'WH020', 195.20, '2024-04-21'), ('B021', 'WH021', 235.70, '2024-04-26'),
('B022', 'WH022', 155.80, '2024-05-02'), ('B023', 'WH023', 225.50, '2024-05-06'), ('B024', 'WH024', 185.90, '2024-05-11'),
('B025', 'WH025', 205.30, '2024-05-16'), ('B026', 'WH026', 175.40, '2024-05-21'), ('B027', 'WH027', 240.80, '2024-05-26'),
('B028', 'WH028', 190.20, '2024-06-02'), ('B029', 'WH029', 220.60, '2024-06-06'), ('B030', 'WH030', 165.70, '2024-06-11'),
('B031', 'WH031', 210.90, '2024-06-16'), ('B032', 'WH032', 195.50, '2024-06-21'), ('B033', 'WH033', 230.40, '2024-06-26'),
('B034', 'WH034', 180.80, '2024-07-02'), ('B035', 'WH035', 215.30, '2024-07-06'), ('B036', 'WH036', 170.60, '2024-07-11'),
('B037', 'WH037', 245.20, '2024-07-16'), ('B038', 'WH038', 200.90, '2024-07-21'), ('B039', 'WH039', 185.40, '2024-07-26'),
('B040', 'WH040', 225.70, '2024-08-02'), ('B041', 'WH041', 160.50, '2024-08-06'), ('B042', 'WH042', 235.80, '2024-08-11'),
('B043', 'WH043', 195.30, '2024-08-16'), ('B044', 'WH044', 210.60, '2024-08-21'), ('B045', 'WH045', 175.90, '2024-08-26'),
('B046', 'WH046', 250.40, '2024-09-02'), ('B047', 'WH047', 190.70, '2024-09-06'), ('B048', 'WH048', 220.50, '2024-09-11'),
('B049', 'WH049', 185.80, '2024-09-16'), ('B050', 'WH050', 205.20, '2024-09-21'), ('B051', 'WH051', 240.60, '2024-09-26'),
('B052', 'WH052', 170.40, '2024-10-02'), ('B053', 'WH053', 215.90, '2024-10-06'), ('B054', 'WH054', 195.70, '2024-10-11'),
('B055', 'WH055', 230.50, '2024-10-16'), ('B056', 'WH056', 180.30, '2024-10-21'), ('B057', 'WH057', 225.80, '2024-10-26'),
('B058', 'WH058', 160.90, '2024-11-02'), ('B059', 'WH059', 245.60, '2024-11-06'), ('B060', 'WH060', 200.40, '2024-11-11'),
('B061', 'WH061', 190.80, '2024-11-16'), ('B062', 'WH062', 235.20, '2024-11-21'), ('B063', 'WH063', 175.50, '2024-11-26'),
('B064', 'WH064', 210.70, '2024-12-02'), ('B065', 'WH065', 185.60, '2024-12-06'), ('B066', 'WH066', 220.90, '2024-12-11'),
('B067', 'WH067', 195.40, '2024-12-16'), ('B068', 'WH068', 230.80, '2024-12-21'), ('B069', 'WH069', 170.20, '2024-12-26'),
('B070', 'WH070', 250.50, '2024-12-31');

-- =========================
-- 70 RECORDS FOR PACKAGING
-- =========================
INSERT INTO packaging (batch_id, package_id, employee_id, packaging_date, quantity) VALUES
('B001', 'PKG001', 'EMP018', '2024-01-17', 50), ('B001', 'PKG002', 'EMP018', '2024-01-17', 30),
('B002', 'PKG003', 'EMP019', '2024-01-22', 40), ('B003', 'PKG004', 'EMP018', '2024-01-27', 60),
('B004', 'PKG005', 'EMP019', '2024-02-03', 35), ('B005', 'PKG006', 'EMP018', '2024-02-07', 45),
('B006', 'PKG007', 'EMP019', '2024-02-12', 55), ('B007', 'PKG008', 'EMP018', '2024-02-17', 25),
('B008', 'PKG009', 'EMP019', '2024-02-22', 65), ('B009', 'PKG010', 'EMP018', '2024-02-27', 38),
('B010', 'PKG011', 'EMP019', '2024-03-03', 42), ('B011', 'PKG012', 'EMP018', '2024-03-07', 48),
('B012', 'PKG013', 'EMP019', '2024-03-12', 52), ('B013', 'PKG014', 'EMP018', '2024-03-17', 33),
('B014', 'PKG015', 'EMP019', '2024-03-22', 47), ('B015', 'PKG016', 'EMP018', '2024-03-27', 44),
('B016', 'PKG017', 'EMP019', '2024-04-03', 56), ('B017', 'PKG018', 'EMP018', '2024-04-07', 39),
('B018', 'PKG019', 'EMP019', '2024-04-12', 61), ('B019', 'PKG020', 'EMP018', '2024-04-17', 28),
('B020', 'PKG021', 'EMP019', '2024-04-22', 53), ('B021', 'PKG022', 'EMP018', '2024-04-27', 41),
('B022', 'PKG023', 'EMP019', '2024-05-03', 49), ('B023', 'PKG024', 'EMP018', '2024-05-07', 36),
('B024', 'PKG025', 'EMP019', '2024-05-12', 58), ('B025', 'PKG026', 'EMP018', '2024-05-17', 32),
('B026', 'PKG027', 'EMP019', '2024-05-22', 46), ('B027', 'PKG028', 'EMP018', '2024-05-27', 43),
('B028', 'PKG029', 'EMP019', '2024-06-03', 57), ('B029', 'PKG030', 'EMP018', '2024-06-07', 34),
('B030', 'PKG031', 'EMP019', '2024-06-12', 62), ('B031', 'PKG032', 'EMP018', '2024-06-17', 29),
('B032', 'PKG033', 'EMP019', '2024-06-22', 54), ('B033', 'PKG034', 'EMP018', '2024-06-27', 37),
('B034', 'PKG035', 'EMP019', '2024-07-03', 51), ('B035', 'PKG036', 'EMP018', '2024-07-07', 45),
('B036', 'PKG037', 'EMP019', '2024-07-12', 59), ('B037', 'PKG038', 'EMP018', '2024-07-17', 31),
('B038', 'PKG039', 'EMP019', '2024-07-22', 63), ('B039', 'PKG040', 'EMP018', '2024-07-27', 26),
('B040', 'PKG041', 'EMP019', '2024-08-03', 48), ('B041', 'PKG042', 'EMP018', '2024-08-07', 52),
('B042', 'PKG043', 'EMP019', '2024-08-12', 35), ('B043', 'PKG044', 'EMP018', '2024-08-17', 60),
('B044', 'PKG045', 'EMP019', '2024-08-22', 41), ('B045', 'PKG046', 'EMP018', '2024-08-27', 55),
('B046', 'PKG047', 'EMP019', '2024-09-03', 33), ('B047', 'PKG048', 'EMP018', '2024-09-07', 47),
('B048', 'PKG049', 'EMP019', '2024-09-12', 64), ('B049', 'PKG050', 'EMP018', '2024-09-17', 38),
('B050', 'PKG051', 'EMP019', '2024-09-22', 49), ('B051', 'PKG052', 'EMP018', '2024-09-27', 44),
('B052', 'PKG053', 'EMP019', '2024-10-03', 56), ('B053', 'PKG054', 'EMP018', '2024-10-07', 30),
('B054', 'PKG055', 'EMP019', '2024-10-12', 61), ('B055', 'PKG056', 'EMP018', '2024-10-17', 42),
('B056', 'PKG057', 'EMP019', '2024-10-22', 53), ('B057', 'PKG058', 'EMP018', '2024-10-27', 39),
('B058', 'PKG059', 'EMP019', '2024-11-03', 58), ('B059', 'PKG060', 'EMP018', '2024-11-07', 27),
('B060', 'PKG061', 'EMP019', '2024-11-12', 62), ('B061', 'PKG062', 'EMP018', '2024-11-17', 34),
('B062', 'PKG063', 'EMP019', '2024-11-22', 50), ('B063', 'PKG064', 'EMP018', '2024-11-27', 46),
('B064', 'PKG065', 'EMP019', '2024-12-03', 57), ('B065', 'PKG066', 'EMP018', '2024-12-07', 31),
('B066', 'PKG067', 'EMP019', '2024-12-12', 63), ('B067', 'PKG068', 'EMP018', '2024-12-17', 29),
('B068', 'PKG069', 'EMP019', '2024-12-22', 54), ('B069', 'PKG070', 'EMP018', '2024-12-27', 43),
('B070', 'PKG001', 'EMP019', '2024-01-01', 65);

-- =========================
-- 70 RECORDS FOR PACKAGING_REPORT
-- =========================
INSERT INTO packaging_report (packaging_report_id, manager_id, batch_id, total_batches, total_packages, report_date) VALUES
('PR001', 'EMP005', 'B001', 2, 80, '2024-01-18'), ('PR002', 'EMP005', 'B002', 1, 40, '2024-01-23'),
('PR003', 'EMP005', 'B003', 1, 60, '2024-01-28'), ('PR004', 'EMP005', 'B004', 1, 35, '2024-02-04'),
('PR005', 'EMP005', 'B005', 1, 45, '2024-02-08'), ('PR006', 'EMP005', 'B006', 1, 55, '2024-02-13'),
('PR007', 'EMP005', 'B007', 1, 25, '2024-02-18'), ('PR008', 'EMP005', 'B008', 1, 65, '2024-02-23'),
('PR009', 'EMP005', 'B009', 1, 38, '2024-02-28'), ('PR010', 'EMP005', 'B010', 1, 42, '2024-03-04'),
('PR011', 'EMP005', 'B011', 1, 48, '2024-03-08'), ('PR012', 'EMP005', 'B012', 1, 52, '2024-03-13'),
('PR013', 'EMP005', 'B013', 1, 33, '2024-03-18'), ('PR014', 'EMP005', 'B014', 1, 47, '2024-03-23'),
('PR015', 'EMP005', 'B015', 1, 44, '2024-03-28'), ('PR016', 'EMP005', 'B016', 1, 56, '2024-04-04'),
('PR017', 'EMP005', 'B017', 1, 39, '2024-04-08'), ('PR018', 'EMP005', 'B018', 1, 61, '2024-04-13'),
('PR019', 'EMP005', 'B019', 1, 28, '2024-04-18'), ('PR020', 'EMP005', 'B020', 1, 53, '2024-04-23'),
('PR021', 'EMP005', 'B021', 1, 41, '2024-04-28'), ('PR022', 'EMP005', 'B022', 1, 49, '2024-05-04'),
('PR023', 'EMP005', 'B023', 1, 36, '2024-05-08'), ('PR024', 'EMP005', 'B024', 1, 58, '2024-05-13'),
('PR025', 'EMP005', 'B025', 1, 32, '2024-05-18'), ('PR026', 'EMP005', 'B026', 1, 46, '2024-05-23'),
('PR027', 'EMP005', 'B027', 1, 43, '2024-05-28'), ('PR028', 'EMP005', 'B028', 1, 57, '2024-06-04'),
('PR029', 'EMP005', 'B029', 1, 34, '2024-06-08'), ('PR030', 'EMP005', 'B030', 1, 62, '2024-06-13'),
('PR031', 'EMP005', 'B031', 1, 29, '2024-06-18'), ('PR032', 'EMP005', 'B032', 1, 54, '2024-06-23'),
('PR033', 'EMP005', 'B033', 1, 37, '2024-06-28'), ('PR034', 'EMP005', 'B034', 1, 51, '2024-07-04'),
('PR035', 'EMP005', 'B035', 1, 45, '2024-07-08'), ('PR036', 'EMP005', 'B036', 1, 59, '2024-07-13'),
('PR037', 'EMP005', 'B037', 1, 31, '2024-07-18'), ('PR038', 'EMP005', 'B038', 1, 63, '2024-07-23'),
('PR039', 'EMP005', 'B039', 1, 26, '2024-07-28'), ('PR040', 'EMP005', 'B040', 1, 48, '2024-08-04'),
('PR041', 'EMP005', 'B041', 1, 52, '2024-08-08'), ('PR042', 'EMP005', 'B042', 1, 35, '2024-08-13'),
('PR043', 'EMP005', 'B043', 1, 60, '2024-08-18'), ('PR044', 'EMP005', 'B044', 1, 41, '2024-08-23'),
('PR045', 'EMP005', 'B045', 1, 55, '2024-08-28'), ('PR046', 'EMP005', 'B046', 1, 33, '2024-09-04'),
('PR047', 'EMP005', 'B047', 1, 47, '2024-09-08'), ('PR048', 'EMP005', 'B048', 1, 64, '2024-09-13'),
('PR049', 'EMP005', 'B049', 1, 38, '2024-09-18'), ('PR050', 'EMP005', 'B050', 1, 49, '2024-09-23'),
('PR051', 'EMP005', 'B051', 1, 44, '2024-09-28'), ('PR052', 'EMP005', 'B052', 1, 56, '2024-10-04'),
('PR053', 'EMP005', 'B053', 1, 30, '2024-10-08'), ('PR054', 'EMP005', 'B054', 1, 61, '2024-10-13'),
('PR055', 'EMP005', 'B055', 1, 42, '2024-10-18'), ('PR056', 'EMP005', 'B056', 1, 53, '2024-10-23'),
('PR057', 'EMP005', 'B057', 1, 39, '2024-10-28'), ('PR058', 'EMP005', 'B058', 1, 58, '2024-11-04'),
('PR059', 'EMP005', 'B059', 1, 27, '2024-11-08'), ('PR060', 'EMP005', 'B060', 1, 62, '2024-11-13'),
('PR061', 'EMP005', 'B061', 1, 34, '2024-11-18'), ('PR062', 'EMP005', 'B062', 1, 50, '2024-11-23'),
('PR063', 'EMP005', 'B063', 1, 46, '2024-11-28'), ('PR064', 'EMP005', 'B064', 1, 57, '2024-12-04'),
('PR065', 'EMP005', 'B065', 1, 31, '2024-12-08'), ('PR066', 'EMP005', 'B066', 1, 63, '2024-12-13'),
('PR067', 'EMP005', 'B067', 1, 29, '2024-12-18'), ('PR068', 'EMP005', 'B068', 1, 54, '2024-12-23'),
('PR069', 'EMP005', 'B069', 1, 43, '2024-12-28'), ('PR070', 'EMP005', 'B070', 1, 65, '2025-01-02');

-- =========================
-- 70 RECORDS FOR REPORT_RECEIVER
-- =========================
INSERT INTO ReportReceiver (report_receiver_id, employee_id, report_date, report_content, report_status) VALUES
(1, 'EMP001', '2024-01-06', 'Farm report received', 'Reviewed'),
(2, 'EMP002', '2024-01-06', 'Quality report received', 'Pending'),
(3, 'EMP003', '2024-01-06', 'Sales report received', 'Reviewed'),
(4, 'EMP004', '2024-01-06', 'HR report received', 'Approved'),
(5, 'EMP005', '2024-01-06', 'Packing report received', 'Pending'),
(6, 'EMP006', '2024-01-06', 'Resource report received', 'Reviewed'),
(7, 'EMP007', '2024-01-11', 'Farm weekly report received', 'Approved'),
(8, 'EMP008', '2024-01-11', 'Production report received', 'Pending'),
(9, 'EMP009', '2024-01-11', 'Revenue report received', 'Reviewed'),
(10, 'EMP016', '2024-01-11', 'Recruitment report received', 'Approved'),
(11, 'EMP010', '2024-01-16', 'Maintenance report received', 'Pending'),
(12, 'EMP012', '2024-01-16', 'Testing report received', 'Reviewed'),
(13, 'EMP014', '2024-01-16', 'Customer report received', 'Approved'),
(14, 'EMP017', '2024-01-16', 'Payroll report received', 'Pending'),
(15, 'EMP018', '2024-01-16', 'Inventory report received', 'Reviewed'),
(16, 'EMP020', '2024-01-16', 'Stock report received', 'Approved'),
(17, 'EMP001', '2024-02-06', 'Farm report Feb received', 'Pending'),
(18, 'EMP002', '2024-02-06', 'Quality report Feb received', 'Reviewed'),
(19, 'EMP003', '2024-02-06', 'Sales report Feb received', 'Approved'),
(20, 'EMP004', '2024-02-06', 'HR report Feb received', 'Pending'),
(21, 'EMP005', '2024-02-06', 'Packing report Feb received', 'Reviewed'),
(22, 'EMP006', '2024-02-06', 'Resource report Feb received', 'Approved'),
(23, 'EMP007', '2024-02-11', 'Farm weekly Feb received', 'Pending'),
(24, 'EMP008', '2024-02-11', 'Production Feb report received', 'Reviewed'),
(25, 'EMP009', '2024-02-11', 'Revenue Feb report received', 'Approved'),
(26, 'EMP016', '2024-02-11', 'Recruitment Feb received', 'Pending'),
(27, 'EMP010', '2024-02-16', 'Maintenance Feb received', 'Reviewed'),
(28, 'EMP012', '2024-02-16', 'Testing Feb report received', 'Approved'),
(29, 'EMP014', '2024-02-16', 'Customer Feb report received', 'Pending'),
(30, 'EMP017', '2024-02-16', 'Payroll Feb report received', 'Reviewed'),
(31, 'EMP018', '2024-02-16', 'Inventory Feb report received', 'Approved'),
(32, 'EMP020', '2024-02-16', 'Stock Feb report received', 'Pending'),
(33, 'EMP001', '2024-03-06', 'Farm report Mar received', 'Reviewed'),
(34, 'EMP002', '2024-03-06', 'Quality report Mar received', 'Approved'),
(35, 'EMP003', '2024-03-06', 'Sales report Mar received', 'Pending'),
(36, 'EMP004', '2024-03-06', 'HR report Mar received', 'Reviewed'),
(37, 'EMP005', '2024-03-06', 'Packing report Mar received', 'Approved'),
(38, 'EMP006', '2024-03-06', 'Resource report Mar received', 'Pending'),
(39, 'EMP007', '2024-03-11', 'Farm weekly Mar received', 'Reviewed'),
(40, 'EMP008', '2024-03-11', 'Production Mar report received', 'Approved'),
(41, 'EMP009', '2024-03-11', 'Revenue Mar report received', 'Pending'),
(42, 'EMP016', '2024-03-11', 'Recruitment Mar received', 'Reviewed'),
(43, 'EMP010', '2024-03-16', 'Maintenance Mar received', 'Approved'),
(44, 'EMP012', '2024-03-16', 'Testing Mar report received', 'Pending'),
(45, 'EMP014', '2024-03-16', 'Customer Mar report received', 'Reviewed'),
(46, 'EMP017', '2024-03-16', 'Payroll Mar report received', 'Approved'),
(47, 'EMP018', '2024-03-16', 'Inventory Mar report received', 'Pending'),
(48, 'EMP020', '2024-03-16', 'Stock Mar report received', 'Reviewed'),
(49, 'EMP025', '2024-04-06', 'Quarterly Q1 report received', 'Approved'),
(50, 'EMP027', '2024-04-06', 'Quality Q1 report received', 'Pending'),
(51, 'EMP029', '2024-04-06', 'Sales Q1 report received', 'Reviewed'),
(52, 'EMP030', '2024-04-06', 'HR Q1 report received', 'Approved'),
(53, 'EMP032', '2024-04-06', 'Packing Q1 report received', 'Pending'),
(54, 'EMP034', '2024-04-06', 'Resource Q1 report received', 'Reviewed'),
(55, 'EMP036', '2024-04-11', 'Farm weekly Apr received', 'Approved'),
(56, 'EMP038', '2024-04-11', 'Production Apr report received', 'Pending'),
(57, 'EMP039', '2024-04-11', 'Revenue Apr report received', 'Reviewed'),
(58, 'EMP040', '2024-04-11', 'Recruitment Apr received', 'Approved'),
(59, 'EMP041', '2024-04-16', 'Maintenance Apr received', 'Pending'),
(60, 'EMP042', '2024-04-16', 'Testing Apr report received', 'Reviewed'),
(61, 'EMP043', '2024-04-16', 'Customer Apr report received', 'Approved'),
(62, 'EMP044', '2024-04-16', 'Payroll Apr report received', 'Pending'),
(63, 'EMP045', '2024-04-16', 'Inventory Apr report received', 'Reviewed'),
(64, 'EMP046', '2024-04-16', 'Stock Apr report received', 'Approved'),
(65, 'EMP047', '2024-05-06', 'Farm report May received', 'Pending'),
(66, 'EMP048', '2024-05-06', 'Quality report May received', 'Reviewed'),
(67, 'EMP049', '2024-05-06', 'Sales report May received', 'Approved'),
(68, 'EMP050', '2024-05-06', 'HR report May received', 'Pending'),
(69, 'EMP051', '2024-05-06', 'Packing report May received', 'Reviewed'),
(70, 'EMP052', '2024-05-06', 'Resource report May received', 'Approved');
select* from department

exec sp_helpconstraint department
alter table department drop constraint FK__departmen__manag__72C60C4A 
alter table department drop column manager_id
-- =========================
-- 70 RECORDS FOR DEPARTMENT_MANAGER
-- =========================
INSERT INTO DepartmentManager (department_id, employee_id, year) VALUES
('D001', 'EMP001', 2024),
('D002', 'EMP002', 2024),
('D003', 'EMP003', 2024),
('D004', 'EMP004', 2024),
('D005', 'EMP005', 2024),
('D006', 'EMP006', 2024),
('D001', 'EMP007', 2023),
('D002', 'EMP008', 2023),
('D003', 'EMP009', 2023),
('D004', 'EMP016', 2023),
('D005', 'EMP018', 2023),
('D006', 'EMP020', 2023),
('D001', 'EMP010', 2022),
('D002', 'EMP012', 2022),
('D003', 'EMP014', 2022),
('D004', 'EMP017', 2022),
('D005', 'EMP019', 2022),
('D006', 'EMP021', 2022),
('D001', 'EMP025', 2021),
('D002', 'EMP027', 2021),
('D003', 'EMP029', 2021),
('D004', 'EMP030', 2021),
('D005', 'EMP032', 2021),
('D006', 'EMP034', 2021),
('D001', 'EMP036', 2020);
insert into DepartmentManager values
('D001', 'EMP032', 2026),
('D002', 'EMP014', 2026),
('D003', 'EMP025', 2026),
('D004', 'EMP034', 2026),
('D005', 'EMP012', 2026),
('D006', 'EMP017', 2026)
-- =========================
-- 70 RECORDS FOR HIVE_PLACEMENT
-- =========================
INSERT INTO Hive_Placement (hive_placement_id, hive_id, tree_id, employee_id, hive_placement_date) VALUES
(1, 1, 1, 'EMP007', '2023-01-10'), (2, 2, 2, 'EMP007', '2023-01-15'), (3, 3, 3, 'EMP007', '2023-01-20'),
(4, 4, 4, 'EMP007', '2023-02-05'), (5, 5, 5, 'EMP007', '2023-02-10'), (6, 6, 6, 'EMP007', '2023-02-15'),
(7, 7, 7, 'EMP007', '2023-03-01'), (8, 8, 8, 'EMP007', '2023-03-05'), (9, 9, 9, 'EMP007', '2023-03-10'),
(10, 10, 10, 'EMP007', '2023-04-12'), (11, 11, 11, 'EMP007', '2023-04-15'), (12, 12, 12, 'EMP007', '2023-04-18'),
(13, 13, 13, 'EMP007', '2023-05-20'), (14, 14, 14, 'EMP007', '2023-05-25'), (15, 15, 15, 'EMP007', '2023-05-30'),
(16, 16, 16, 'EMP007', '2023-06-10'), (17, 17, 17, 'EMP007', '2023-06-15'), (18, 18, 18, 'EMP007', '2023-06-20'),
(19, 19, 19, 'EMP007', '2023-07-05'), (20, 20, 20, 'EMP007', '2023-07-10'), (21, 21, 21, 'EMP007', '2023-07-15'),
(22, 22, 22, 'EMP007', '2023-08-20'), (23, 23, 23, 'EMP007', '2023-08-25'), (24, 24, 24, 'EMP007', '2023-08-30'),
(25, 25, 25, 'EMP007', '2023-09-10'), (26, 26, 26, 'EMP007', '2023-09-15'), (27, 27, 27, 'EMP007', '2023-09-20'),
(28, 28, 28, 'EMP007', '2023-10-05'), (29, 29, 29, 'EMP007', '2023-10-10'), (30, 30, 30, 'EMP007', '2023-10-15'),
(31, 31, 31, 'EMP007', '2024-01-08'), (32, 32, 32, 'EMP007', '2024-01-12'), (33, 33, 33, 'EMP007', '2024-01-16'),
(34, 34, 34, 'EMP007', '2024-02-20'), (35, 35, 35, 'EMP007', '2024-02-24'), (36, 36, 36, 'EMP007', '2024-02-28'),
(37, 37, 37, 'EMP007', '2024-03-15'), (38, 38, 38, 'EMP007', '2024-03-18'), (39, 39, 39, 'EMP007', '2024-03-22'),
(40, 40, 40, 'EMP007', '2024-04-10'), (41, 41, 41, 'EMP007', '2024-04-14'), (42, 42, 42, 'EMP007', '2024-04-18'),
(43, 43, 43, 'EMP007', '2024-05-05'), (44, 44, 44, 'EMP007', '2024-05-09'), (45, 45, 45, 'EMP007', '2024-05-13'),
(46, 46, 46, 'EMP007', '2024-06-25'), (47, 47, 47, 'EMP007', '2024-06-28'), (48, 48, 48, 'EMP007', '2024-07-02'),
(49, 49, 49, 'EMP007', '2024-07-20'), (50, 50, 50, 'EMP007', '2024-07-24'), (51, 51, 51, 'EMP007', '2024-07-28'),
(52, 52, 52, 'EMP007', '2024-08-15'), (53, 53, 53, 'EMP007', '2024-08-19'), (54, 54, 54, 'EMP007', '2024-08-23'),
(55, 55, 55, 'EMP007', '2024-09-10'), (56, 56, 56, 'EMP007', '2024-09-14'), (57, 57, 57, 'EMP007', '2024-09-18'),
(58, 58, 58, 'EMP007', '2024-10-05'), (59, 59, 59, 'EMP007', '2024-10-09'), (60, 60, 60, 'EMP007', '2024-10-13'),
(61, 61, 61, 'EMP007', '2025-01-20'), (62, 62, 62, 'EMP007', '2025-01-24'), (63, 63, 63, 'EMP007', '2025-01-28'),
(64, 64, 64, 'EMP007', '2025-02-15'), (65, 65, 65, 'EMP007', '2025-02-19'), (66, 66, 66, 'EMP007', '2025-02-23'),
(67, 67, 67, 'EMP007', '2025-03-10'), (68, 68, 68, 'EMP007', '2025-03-14'), (69, 69, 69, 'EMP007', '2025-03-18'),
(70, 70, 70, 'EMP007', '2025-04-05');

-- =========================
-- 70 RECORDS FOR HIVE_HARVEST
-- =========================
INSERT INTO Hive_Harvest (harvest_id, hive_id, employee_id, container_id, hive_harvest_date) VALUES
(1, 1, 'EMP008', 1, '2024-06-10'), (2, 2, 'EMP008', 1, '2024-06-15'), (3, 3, 'EMP008', 2, '2024-06-20'),
(4, 4, 'EMP008', 2, '2024-07-05'), (5, 5, 'EMP008', 3, '2024-07-10'), (6, 6, 'EMP008', 3, '2024-07-15'),
(7, 7, 'EMP008', 4, '2024-08-01'), (8, 8, 'EMP008', 4, '2024-08-05'), (9, 9, 'EMP008', 5, '2024-08-10'),
(10, 10, 'EMP008', 5, '2024-08-15'), (11, 11, 'EMP008', 6, '2024-09-01'), (12, 12, 'EMP008', 6, '2024-09-05'),
(13, 13, 'EMP008', 7, '2024-09-10'), (14, 14, 'EMP008', 7, '2024-09-15'), (15, 15, 'EMP008', 8, '2024-09-20'),
(16, 16, 'EMP008', 8, '2024-10-05'), (17, 17, 'EMP008', 9, '2024-10-10'), (18, 18, 'EMP008', 9, '2024-10-15'),
(19, 19, 'EMP008', 10, '2024-10-20'), (20, 20, 'EMP008', 10, '2024-11-01'), (21, 21, 'EMP008', 11, '2024-11-05'),
(22, 22, 'EMP008', 11, '2024-11-10'), (23, 23, 'EMP008', 12, '2024-11-15'), (24, 24, 'EMP008', 12, '2024-11-20'),
(25, 25, 'EMP008', 13, '2024-11-25'), (26, 26, 'EMP008', 13, '2024-12-01'), (27, 27, 'EMP008', 14, '2024-12-05'),
(28, 28, 'EMP008', 14, '2024-12-10'), (29, 29, 'EMP008', 15, '2024-12-15'), (30, 30, 'EMP008', 15, '2024-12-20'),
(31, 31, 'EMP008', 16, '2025-01-05'), (32, 32, 'EMP008', 16, '2025-01-10'), (33, 33, 'EMP008', 17, '2025-01-15'),
(34, 34, 'EMP008', 17, '2025-01-20'), (35, 35, 'EMP008', 18, '2025-02-01'), (36, 36, 'EMP008', 18, '2025-02-05'),
(37, 37, 'EMP008', 19, '2025-02-10'), (38, 38, 'EMP008', 19, '2025-02-15'), (39, 39, 'EMP008', 20, '2025-02-20'),
(40, 40, 'EMP008', 20, '2025-03-01'), (41, 41, 'EMP008', 21, '2025-03-05'), (42, 42, 'EMP008', 21, '2025-03-10'),
(43, 43, 'EMP008', 22, '2025-03-15'), (44, 44, 'EMP008', 22, '2025-03-20'), (45, 45, 'EMP008', 23, '2025-04-01'),
(46, 46, 'EMP008', 23, '2025-04-05'), (47, 47, 'EMP008', 24, '2025-04-10'), (48, 48, 'EMP008', 24, '2025-04-15'),
(49, 49, 'EMP008', 25, '2025-04-20'), (50, 50, 'EMP008', 25, '2025-05-01'), (51, 51, 'EMP008', 1, '2025-05-05'),
(52, 52, 'EMP008', 2, '2025-05-10'), (53, 53, 'EMP008', 3, '2025-05-15'), (54, 54, 'EMP008', 4, '2025-05-20'),
(55, 55, 'EMP008', 5, '2025-06-01'), (56, 56, 'EMP008', 6, '2025-06-05'), (57, 57, 'EMP008', 7, '2025-06-10'),
(58, 58, 'EMP008', 8, '2025-06-15'), (59, 59, 'EMP008', 9, '2025-06-20'), (60, 60, 'EMP008', 10, '2025-07-01'),
(61, 61, 'EMP008', 11, '2025-07-05'), (62, 62, 'EMP008', 12, '2025-07-10'), (63, 63, 'EMP008', 13, '2025-07-15'),
(64, 64, 'EMP008', 14, '2025-07-20'), (65, 65, 'EMP008', 15, '2025-08-01'), (66, 66, 'EMP008', 16, '2025-08-05'),
(67, 67, 'EMP008', 17, '2025-08-10'), (68, 68, 'EMP008', 18, '2025-08-15'), (69, 69, 'EMP008', 19, '2025-08-20'),
(70, 70, 'EMP008', 20, '2025-09-01');

-- =========================
-- 70 RECORDS FOR OPERATION
-- =========================
INSERT INTO Operation (operation_id, operation_name, operation_date, operation_result, employee_id, hive_id) VALUES
(1, 'Hive Inspection', '2024-01-15', 'Healthy', 'EMP007', 1),
(2, 'Queen Check', '2024-01-20', 'Queen Present', 'EMP007', 2),
(3, 'Disease Check', '2024-01-25', 'No Disease', 'EMP007', 3),
(4, 'Hive Feeding', '2024-02-01', 'Completed', 'EMP007', 4),
(5, 'Frame Replacement', '2024-02-05', 'Done', 'EMP007', 5),
(6, 'Hive Cleaning', '2024-02-10', 'Cleaned', 'EMP007', 6),
(7, 'Pest Control', '2024-02-15', 'Treated', 'EMP007', 7),
(8, 'Hive Inspection', '2024-03-01', 'Good', 'EMP007', 8),
(9, 'Queen Check', '2024-03-05', 'Queen Healthy', 'EMP007', 9),
(10, 'Disease Check', '2024-03-10', 'Clean', 'EMP007', 10),
(11, 'Hive Feeding', '2024-03-15', 'Fed', 'EMP007', 11),
(12, 'Frame Replacement', '2024-04-01', 'Replaced', 'EMP007', 12),
(13, 'Hive Cleaning', '2024-04-05', 'Completed', 'EMP007', 13),
(14, 'Pest Control', '2024-04-10', 'Done', 'EMP007', 14),
(15, 'Hive Inspection', '2024-04-15', 'Excellent', 'EMP007', 15),
(16, 'Queen Check', '2024-05-01', 'Queen Laying', 'EMP007', 16),
(17, 'Disease Check', '2024-05-05', 'Healthy', 'EMP007', 17),
(18, 'Hive Feeding', '2024-05-10', 'Completed', 'EMP007', 18),
(19, 'Frame Replacement', '2024-05-15', 'Done', 'EMP007', 19),
(20, 'Hive Cleaning', '2024-06-01', 'Cleaned', 'EMP007', 20),
(21, 'Pest Control', '2024-06-05', 'Treated', 'EMP007', 21),
(22, 'Hive Inspection', '2024-06-10', 'Good', 'EMP007', 22),
(23, 'Queen Check', '2024-06-15', 'Queen Present', 'EMP007', 23),
(24, 'Disease Check', '2024-07-01', 'No Issues', 'EMP007', 24),
(25, 'Hive Feeding', '2024-07-05', 'Fed', 'EMP007', 25),
(26, 'Frame Replacement', '2024-07-10', 'Replaced', 'EMP007', 26),
(27, 'Hive Cleaning', '2024-07-15', 'Completed', 'EMP007', 27),
(28, 'Pest Control', '2024-08-01', 'Done', 'EMP007', 28),
(29, 'Hive Inspection', '2024-08-05', 'Excellent', 'EMP007', 29),
(30, 'Queen Check', '2024-08-10', 'Queen Healthy', 'EMP007', 30),
(31, 'Disease Check', '2024-08-15', 'Clean', 'EMP007', 31),
(32, 'Hive Feeding', '2024-09-01', 'Completed', 'EMP007', 32),
(33, 'Frame Replacement', '2024-09-05', 'Done', 'EMP007', 33),
(34, 'Hive Cleaning', '2024-09-10', 'Cleaned', 'EMP007', 34),
(35, 'Pest Control', '2024-09-15', 'Treated', 'EMP007', 35),
(36, 'Hive Inspection', '2024-10-01', 'Good', 'EMP007', 36),
(37, 'Queen Check', '2024-10-05', 'Queen Laying', 'EMP007', 37),
(38, 'Disease Check', '2024-10-10', 'Healthy', 'EMP007', 38),
(39, 'Hive Feeding', '2024-10-15', 'Fed', 'EMP007', 39),
(40, 'Frame Replacement', '2024-11-01', 'Replaced', 'EMP007', 40),
(41, 'Hive Cleaning', '2024-11-05', 'Completed', 'EMP007', 41),
(42, 'Pest Control', '2024-11-10', 'Done', 'EMP007', 42),
(43, 'Hive Inspection', '2024-11-15', 'Excellent', 'EMP007', 43),
(44, 'Queen Check', '2024-12-01', 'Queen Present', 'EMP007', 44),
(45, 'Disease Check', '2024-12-05', 'No Disease', 'EMP007', 45),
(46, 'Hive Feeding', '2024-12-10', 'Completed', 'EMP007', 46),
(47, 'Frame Replacement', '2024-12-15', 'Done', 'EMP007', 47),
(48, 'Hive Cleaning', '2025-01-05', 'Cleaned', 'EMP007', 48),
(49, 'Pest Control', '2025-01-10', 'Treated', 'EMP007', 49),
(50, 'Hive Inspection', '2025-01-15', 'Good', 'EMP007', 50),
(51, 'Queen Check', '2025-02-01', 'Queen Healthy', 'EMP007', 51),
(52, 'Disease Check', '2025-02-05', 'Clean', 'EMP007', 52),
(53, 'Hive Feeding', '2025-02-10', 'Fed', 'EMP007', 53),
(54, 'Frame Replacement', '2025-02-15', 'Replaced', 'EMP007', 54),
(55, 'Hive Cleaning', '2025-03-01', 'Completed', 'EMP007', 55),
(56, 'Pest Control', '2025-03-05', 'Done', 'EMP007', 56),
(57, 'Hive Inspection', '2025-03-10', 'Excellent', 'EMP007', 57),
(58, 'Queen Check', '2025-03-15', 'Queen Laying', 'EMP007', 58),
(59, 'Disease Check', '2025-04-01', 'Healthy', 'EMP007', 59),
(60, 'Hive Feeding', '2025-04-05', 'Completed', 'EMP007', 60),
(61, 'Frame Replacement', '2025-04-10', 'Done', 'EMP007', 61),
(62, 'Hive Cleaning', '2025-04-15', 'Cleaned', 'EMP007', 62),
(63, 'Pest Control', '2025-05-01', 'Treated', 'EMP007', 63),
(64, 'Hive Inspection', '2025-05-05', 'Good', 'EMP007', 64),
(65, 'Queen Check', '2025-05-10', 'Queen Present', 'EMP007', 65),
(66, 'Disease Check', '2025-05-15', 'No Issues', 'EMP007', 66),
(67, 'Hive Feeding', '2025-06-01', 'Fed', 'EMP007', 67),
(68, 'Frame Replacement', '2025-06-05', 'Replaced', 'EMP007', 68),
(69, 'Hive Cleaning', '2025-06-10', 'Completed', 'EMP007', 69),
(70, 'Pest Control', '2025-06-15', 'Done', 'EMP007', 70);

-- =========================
-- 70 RECORDS FOR SUPPLIER_CONTACT
-- =========================
INSERT INTO SupplierContact (supplier_id, supplier_phone) VALUES
(1, '0411111111'), (1, '0411111112'), (2, '0422222222'), (3, '0433333333'),
(4, '0444444444'), (5, '0455555555'), (6, '0466666666'), (7, '0477777777'),
(8, '0488888888'), (9, '0499999999'), (10, '0410101010'), (11, '0411111113'),
(12, '0412121212'), (13, '0413131313'), (14, '0414141414'), (15, '0415151515'),
(16, '0416161616'), (17, '0417171717'), (18, '0418181818'), (19, '0419191919'),
(20, '0420202020'), (21, '0421212121'), (22, '0422222223'), (23, '0423232323'),
(24, '0424242424'), (25, '0425252525'), (1, '0426262626'), (2, '0427272727'),
(3, '0428282828'), (4, '0429292929'), (5, '0430303030'), (6, '0431313131'),
(7, '0432323232'), (8, '0433333334'), (9, '0434343434'), (10, '0435353535'),
(11, '0436363636'), (12, '0437373737'), (13, '0438383838'), (14, '0439393939'),
(15, '0440404040'), (16, '0441414141'), (17, '0442424242'), (18, '0443434343'),
(19, '0444444445'), (20, '0445454545'), (21, '0446464646'), (22, '0447474747'),
(23, '0448484848'), (24, '0449494949'), (25, '0450505050'), (1, '0451515151'),
(2, '0452525252'), (3, '0453535353'), (4, '0454545454'), (5, '0455555556'),
(6, '0456565656'), (7, '0457575757'), (8, '0458585858'), (9, '0459595959'),
(10, '0460606060'), (11, '0461616161'), (12, '0462626262'), (13, '0463636363'),
(14, '0464646464'), (15, '0465656565'), (16, '0466666667'), (17, '0467676767'),
(18, '0468686868'), (19, '0469696969'), (20, '0470707070');

-- =========================
-- 70 RECORDS FOR HIVE_PURCHASE
-- =========================
INSERT INTO Hive_Purchase (hive_purchase_id, employee_id, supplier_id, hive_purchase_date, hive_purchase_quantity) VALUES
(1, 'EMP001', 1, '2023-01-10', 10), (2, 'EMP001', 2, '2023-01-15', 15), (3, 'EMP001', 3, '2023-02-05', 8),
(4, 'EMP001', 4, '2023-02-10', 12), (5, 'EMP001', 5, '2023-03-01', 20), (6, 'EMP001', 6, '2023-03-15', 5),
(7, 'EMP001', 7, '2023-04-01', 25), (8, 'EMP001', 8, '2023-04-15', 18), (9, 'EMP001', 9, '2023-05-01', 30),
(10, 'EMP001', 10, '2023-05-15', 22), (11, 'EMP001', 11, '2023-06-01', 14), (12, 'EMP001', 12, '2023-06-15', 9),
(13, 'EMP001', 13, '2023-07-01', 35), (14, 'EMP001', 14, '2023-07-15', 28), (15, 'EMP001', 15, '2023-08-01', 40),
(16, 'EMP001', 16, '2023-08-15', 32), (17, 'EMP001', 17, '2023-09-01', 45), (18, 'EMP001', 18, '2023-09-15', 38),
(19, 'EMP001', 19, '2023-10-01', 50), (20, 'EMP001', 20, '2023-10-15', 42), (21, 'EMP001', 21, '2023-11-01', 55),
(22, 'EMP001', 22, '2023-11-15', 48), (23, 'EMP001', 23, '2023-12-01', 60), (24, 'EMP001', 24, '2023-12-15', 52),
(25, 'EMP001', 25, '2024-01-05', 65), (26, 'EMP001', 1, '2024-01-20', 58), (27, 'EMP001', 2, '2024-02-05', 70),
(28, 'EMP001', 3, '2024-02-20', 62), (29, 'EMP001', 4, '2024-03-05', 75), (30, 'EMP001', 5, '2024-03-20', 68),
(31, 'EMP001', 6, '2024-04-05', 80), (32, 'EMP001', 7, '2024-04-20', 72), (33, 'EMP001', 8, '2024-05-05', 85),
(34, 'EMP001', 9, '2024-05-20', 78), (35, 'EMP001', 10, '2024-06-05', 90), (36, 'EMP001', 11, '2024-06-20', 82),
(37, 'EMP001', 12, '2024-07-05', 95), (38, 'EMP001', 13, '2024-07-20', 88), (39, 'EMP001', 14, '2024-08-05', 100),
(40, 'EMP001', 15, '2024-08-20', 92), (41, 'EMP001', 16, '2024-09-05', 105), (42, 'EMP001', 17, '2024-09-20', 98),
(43, 'EMP001', 18, '2024-10-05', 110), (44, 'EMP001', 19, '2024-10-20', 102), (45, 'EMP001', 20, '2024-11-05', 115),
(46, 'EMP001', 21, '2024-11-20', 108), (47, 'EMP001', 22, '2024-12-05', 120), (48, 'EMP001', 23, '2024-12-20', 112),
(49, 'EMP001', 24, '2025-01-05', 125), (50, 'EMP001', 25, '2025-01-20', 118), (51, 'EMP001', 1, '2025-02-05', 130),
(52, 'EMP001', 2, '2025-02-20', 122), (53, 'EMP001', 3, '2025-03-05', 135), (54, 'EMP001', 4, '2025-03-20', 128),
(55, 'EMP001', 5, '2025-04-05', 140), (56, 'EMP001', 6, '2025-04-20', 132), (57, 'EMP001', 7, '2025-05-05', 145),
(58, 'EMP001', 8, '2025-05-20', 138), (59, 'EMP001', 9, '2025-06-05', 150), (60, 'EMP001', 10, '2025-06-20', 142),
(61, 'EMP001', 11, '2025-07-05', 155), (62, 'EMP001', 12, '2025-07-20', 148), (63, 'EMP001', 13, '2025-08-05', 160),
(64, 'EMP001', 14, '2025-08-20', 152), (65, 'EMP001', 15, '2025-09-05', 165), (66, 'EMP001', 16, '2025-09-20', 158),
(67, 'EMP001', 17, '2025-10-05', 170), (68, 'EMP001', 18, '2025-10-20', 162), (69, 'EMP001', 19, '2025-11-05', 175),
(70, 'EMP001', 20, '2025-11-20', 168);

-- =========================
-- 70 RECORDS FOR DISTRIBUTOR_CONTACT
-- =========================
INSERT INTO DistributorContact (distributor_id, distributor_phone) VALUES
(1, '0511111111'), (1, '0511111112'), (2, '0522222222'), (3, '0533333333'),
(4, '0544444444'), (5, '0555555555'), (6, '0566666666'), (7, '0577777777'),
(8, '0588888888'), (9, '0599999999'), (10, '0510101010'), (11, '0511111113'),
(12, '0512121212'), (13, '0513131313'), (14, '0514141414'), (15, '0515151515'),
(16, '0516161616'), (17, '0517171717'), (18, '0518181818'), (19, '0519191919'),
(20, '0520202020'), (21, '0521212121'), (22, '0522222223'), (23, '0523232323'),
(24, '0524242424'), (25, '0525252525'), (1, '0526262626'), (2, '0527272727'),
(3, '0528282828'), (4, '0529292929'), (5, '0530303030'), (6, '0531313131'),
(7, '0532323232'), (8, '0533333334'), (9, '0534343434'), (10, '0535353535'),
(11, '0536363636'), (12, '0537373737'), (13, '0538383838'), (14, '0539393939'),
(15, '0540404040'), (16, '0541414141'), (17, '0542424242'), (18, '0543434343'),
(19, '0544444445'), (20, '0545454545'), (21, '0546464646'), (22, '0547474747'),
(23, '0548484848'), (24, '0549494949'), (25, '0550505050'), (1, '0551515151'),
(2, '0552525252'), (3, '0553535353'), (4, '0554545454'), (5, '0555555556'),
(6, '0556565656'), (7, '0557575757'), (8, '0558585858'), (9, '0559595959'),
(10, '0560606060'), (11, '0561616161'), (12, '0562626262'), (13, '0563636363'),
(14, '0564646464'), (15, '0565656565'), (16, '0566666667'), (17, '0567676767'),
(18, '0568686868'), (19, '0569696969'), (20, '0570707070');

-- =========================
-- 70 RECORDS FOR DEAL
-- =========================
INSERT INTO Deal (deal_id, price_per_kilogram, deal_date, deal_total_amount, distributor_id, employee_id) VALUES
(1, 12.50, '2024-01-10', 12500, 1, 'EMP003'), (2, 12.75, '2024-01-15', 19125, 2, 'EMP003'),
(3, 13.00, '2024-01-20', 13000, 3, 'EMP003'), (4, 13.25, '2024-01-25', 19875, 4, 'EMP003'),
(5, 13.50, '2024-02-01', 13500, 5, 'EMP003'), (6, 13.75, '2024-02-05', 20625, 6, 'EMP003'),
(7, 14.00, '2024-02-10', 14000, 7, 'EMP003'), (8, 14.25, '2024-02-15', 21375, 8, 'EMP003'),
(9, 14.50, '2024-02-20', 14500, 9, 'EMP003'), (10, 14.75, '2024-02-25', 22125, 10, 'EMP003'),
(11, 15.00, '2024-03-01', 15000, 11, 'EMP003'), (12, 15.25, '2024-03-05', 22875, 12, 'EMP003'),
(13, 15.50, '2024-03-10', 15500, 13, 'EMP003'), (14, 15.75, '2024-03-15', 23625, 14, 'EMP003'),
(15, 16.00, '2024-03-20', 16000, 15, 'EMP003'), (16, 16.25, '2024-03-25', 24375, 16, 'EMP003'),
(17, 16.50, '2024-04-01', 16500, 17, 'EMP003'), (18, 16.75, '2024-04-05', 25125, 18, 'EMP003'),
(19, 17.00, '2024-04-10', 17000, 19, 'EMP003'), (20, 17.25, '2024-04-15', 25875, 20, 'EMP003'),
(21, 17.50, '2024-04-20', 17500, 21, 'EMP003'), (22, 17.75, '2024-04-25', 26625, 22, 'EMP003'),
(23, 18.00, '2024-05-01', 18000, 23, 'EMP003'), (24, 18.25, '2024-05-05', 27375, 24, 'EMP003'),
(25, 18.50, '2024-05-10', 18500, 25, 'EMP003'), (26, 18.75, '2024-05-15', 28125, 1, 'EMP003'),
(27, 19.00, '2024-05-20', 19000, 2, 'EMP003'), (28, 19.25, '2024-05-25', 28875, 3, 'EMP003'),
(29, 19.50, '2024-06-01', 19500, 4, 'EMP003'), (30, 19.75, '2024-06-05', 29625, 5, 'EMP003'),
(31, 20.00, '2024-06-10', 20000, 6, 'EMP003'), (32, 20.25, '2024-06-15', 30375, 7, 'EMP003'),
(33, 20.50, '2024-06-20', 20500, 8, 'EMP003'), (34, 20.75, '2024-06-25', 31125, 9, 'EMP003'),
(35, 21.00, '2024-07-01', 21000, 10, 'EMP003'), (36, 21.25, '2024-07-05', 31875, 11, 'EMP003'),
(37, 21.50, '2024-07-10', 21500, 12, 'EMP003'), (38, 21.75, '2024-07-15', 32625, 13, 'EMP003'),
(39, 22.00, '2024-07-20', 22000, 14, 'EMP003'), (40, 22.25, '2024-07-25', 33375, 15, 'EMP003'),
(41, 22.50, '2024-08-01', 22500, 16, 'EMP003'), (42, 22.75, '2024-08-05', 34125, 17, 'EMP003'),
(43, 23.00, '2024-08-10', 23000, 18, 'EMP003'), (44, 23.25, '2024-08-15', 34875, 19, 'EMP003'),
(45, 23.50, '2024-08-20', 23500, 20, 'EMP003'), (46, 23.75, '2024-08-25', 35625, 21, 'EMP003'),
(47, 24.00, '2024-09-01', 24000, 22, 'EMP003'), (48, 24.25, '2024-09-05', 36375, 23, 'EMP003'),
(49, 24.50, '2024-09-10', 24500, 24, 'EMP003'), (50, 24.75, '2024-09-15', 37125, 25, 'EMP003'),
(51, 25.00, '2024-09-20', 25000, 1, 'EMP003'), (52, 25.25, '2024-09-25', 37875, 2, 'EMP003'),
(53, 25.50, '2024-10-01', 25500, 3, 'EMP003'), (54, 25.75, '2024-10-05', 38625, 4, 'EMP003'),
(55, 26.00, '2024-10-10', 26000, 5, 'EMP003'), (56, 26.25, '2024-10-15', 39375, 6, 'EMP003'),
(57, 26.50, '2024-10-20', 26500, 7, 'EMP003'), (58, 26.75, '2024-10-25', 40125, 8, 'EMP003'),
(59, 27.00, '2024-11-01', 27000, 9, 'EMP003'), (60, 27.25, '2024-11-05', 40875, 10, 'EMP003'),
(61, 27.50, '2024-11-10', 27500, 11, 'EMP003'), (62, 27.75, '2024-11-15', 41625, 12, 'EMP003'),
(63, 28.00, '2024-11-20', 28000, 13, 'EMP003'), (64, 28.25, '2024-11-25', 42375, 14, 'EMP003'),
(65, 28.50, '2024-12-01', 28500, 15, 'EMP003'), (66, 28.75, '2024-12-05', 43125, 16, 'EMP003'),
(67, 29.00, '2024-12-10', 29000, 17, 'EMP003'), (68, 29.25, '2024-12-15', 43875, 18, 'EMP003'),
(69, 29.50, '2024-12-20', 29500, 19, 'EMP003'), (70, 29.75, '2024-12-25', 44625, 20, 'EMP003');

-- =========================
-- 70 RECORDS FOR TRANSACTION_DEAL
-- =========================
INSERT INTO Transaction_Deal (transaction_id, transaction_method, transaction_amount, transaction_date, deal_id) VALUES
(1, 'Bank Transfer', 12500, '2024-01-11', 1), (2, 'Bank Transfer', 19125, '2024-01-16', 2),
(3, 'Cash', 13000, '2024-01-21', 3), (4, 'Bank Transfer', 19875, '2024-01-26', 4),
(5, 'Online', 13500, '2024-02-02', 5), (6, 'Bank Transfer', 20625, '2024-02-06', 6),
(7, 'Cash', 14000, '2024-02-11', 7), (8, 'Bank Transfer', 21375, '2024-02-16', 8),
(9, 'Online', 14500, '2024-02-21', 9), (10, 'Bank Transfer', 22125, '2024-02-26', 10),
(11, 'Cash', 15000, '2024-03-02', 11), (12, 'Bank Transfer', 22875, '2024-03-06', 12),
(13, 'Online', 15500, '2024-03-11', 13), (14, 'Bank Transfer', 23625, '2024-03-16', 14),
(15, 'Cash', 16000, '2024-03-21', 15), (16, 'Bank Transfer', 24375, '2024-03-26', 16),
(17, 'Online', 16500, '2024-04-02', 17), (18, 'Bank Transfer', 25125, '2024-04-06', 18),
(19, 'Cash', 17000, '2024-04-11', 19), (20, 'Bank Transfer', 25875, '2024-04-16', 20),
(21, 'Online', 17500, '2024-04-21', 21), (22, 'Bank Transfer', 26625, '2024-04-26', 22),
(23, 'Cash', 18000, '2024-05-02', 23), (24, 'Bank Transfer', 27375, '2024-05-06', 24),
(25, 'Online', 18500, '2024-05-11', 25), (26, 'Bank Transfer', 28125, '2024-05-16', 26),
(27, 'Cash', 19000, '2024-05-21', 27), (28, 'Bank Transfer', 28875, '2024-05-26', 28),
(29, 'Online', 19500, '2024-06-02', 29), (30, 'Bank Transfer', 29625, '2024-06-06', 30),
(31, 'Cash', 20000, '2024-06-11', 31), (32, 'Bank Transfer', 30375, '2024-06-16', 32),
(33, 'Online', 20500, '2024-06-21', 33), (34, 'Bank Transfer', 31125, '2024-06-26', 34),
(35, 'Cash', 21000, '2024-07-02', 35), (36, 'Bank Transfer', 31875, '2024-07-06', 36),
(37, 'Online', 21500, '2024-07-11', 37), (38, 'Bank Transfer', 32625, '2024-07-16', 38),
(39, 'Cash', 22000, '2024-07-21', 39), (40, 'Bank Transfer', 33375, '2024-07-26', 40),
(41, 'Online', 22500, '2024-08-02', 41), (42, 'Bank Transfer', 34125, '2024-08-06', 42),
(43, 'Cash', 23000, '2024-08-11', 43), (44, 'Bank Transfer', 34875, '2024-08-16', 44),
(45, 'Online', 23500, '2024-08-21', 45), (46, 'Bank Transfer', 35625, '2024-08-26', 46),
(47, 'Cash', 24000, '2024-09-02', 47), (48, 'Bank Transfer', 36375, '2024-09-06', 48),
(49, 'Online', 24500, '2024-09-11', 49), (50, 'Bank Transfer', 37125, '2024-09-16', 50),
(51, 'Cash', 25000, '2024-09-21', 51), (52, 'Bank Transfer', 37875, '2024-09-26', 52),
(53, 'Online', 25500, '2024-10-02', 53), (54, 'Bank Transfer', 38625, '2024-10-06', 54),
(55, 'Cash', 26000, '2024-10-11', 55), (56, 'Bank Transfer', 39375, '2024-10-16', 56),
(57, 'Online', 26500, '2024-10-21', 57), (58, 'Bank Transfer', 40125, '2024-10-26', 58),
(59, 'Cash', 27000, '2024-11-02', 59), (60, 'Bank Transfer', 40875, '2024-11-06', 60),
(61, 'Online', 27500, '2024-11-11', 61), (62, 'Bank Transfer', 41625, '2024-11-16', 62),
(63, 'Cash', 28000, '2024-11-21', 63), (64, 'Bank Transfer', 42375, '2024-11-26', 64),
(65, 'Online', 28500, '2024-12-02', 65), (66, 'Bank Transfer', 43125, '2024-12-06', 66),
(67, 'Cash', 29000, '2024-12-11', 67), (68, 'Bank Transfer', 43875, '2024-12-16', 68),
(69, 'Online', 29500, '2024-12-21', 69), (70, 'Bank Transfer', 44625, '2024-12-26', 70);

-- =========================
-- 70 RECORDS FOR DISNOTIFICATION
-- =========================
INSERT INTO disNotification (notification_id, transaction_id, receiver_id, sender_id) VALUES
(1, 1, 'EMP003', 'EMP001'), (2, 2, 'EMP003', 'EMP001'), (3, 3, 'EMP003', 'EMP001'),
(4, 4, 'EMP003', 'EMP001'), (5, 5, 'EMP003', 'EMP001'), (6, 6, 'EMP003', 'EMP001'),
(7, 7, 'EMP003', 'EMP001'), (8, 8, 'EMP003', 'EMP001'), (9, 9, 'EMP003', 'EMP001'),
(10, 10, 'EMP003', 'EMP001'), (11, 11, 'EMP003', 'EMP001'), (12, 12, 'EMP003', 'EMP001'),
(13, 13, 'EMP003', 'EMP001'), (14, 14, 'EMP003', 'EMP001'), (15, 15, 'EMP003', 'EMP001'),
(16, 16, 'EMP003', 'EMP001'), (17, 17, 'EMP003', 'EMP001'), (18, 18, 'EMP003', 'EMP001'),
(19, 19, 'EMP003', 'EMP001'), (20, 20, 'EMP003', 'EMP001'), (21, 21, 'EMP003', 'EMP001'),
(22, 22, 'EMP003', 'EMP001'), (23, 23, 'EMP003', 'EMP001'), (24, 24, 'EMP003', 'EMP001'),
(25, 25, 'EMP003', 'EMP001'), (26, 26, 'EMP003', 'EMP001'), (27, 27, 'EMP003', 'EMP001'),
(28, 28, 'EMP003', 'EMP001'), (29, 29, 'EMP003', 'EMP001'), (30, 30, 'EMP003', 'EMP001'),
(31, 31, 'EMP003', 'EMP001'), (32, 32, 'EMP003', 'EMP001'), (33, 33, 'EMP003', 'EMP001'),
(34, 34, 'EMP003', 'EMP001'), (35, 35, 'EMP003', 'EMP001'), (36, 36, 'EMP003', 'EMP001'),
(37, 37, 'EMP003', 'EMP001'), (38, 38, 'EMP003', 'EMP001'), (39, 39, 'EMP003', 'EMP001'),
(40, 40, 'EMP003', 'EMP001'), (41, 41, 'EMP003', 'EMP001'), (42, 42, 'EMP003', 'EMP001'),
(43, 43, 'EMP003', 'EMP001'), (44, 44, 'EMP003', 'EMP001'), (45, 45, 'EMP003', 'EMP001'),
(46, 46, 'EMP003', 'EMP001'), (47, 47, 'EMP003', 'EMP001'), (48, 48, 'EMP003', 'EMP001'),
(49, 49, 'EMP003', 'EMP001'), (50, 50, 'EMP003', 'EMP001'), (51, 51, 'EMP003', 'EMP001'),
(52, 52, 'EMP003', 'EMP001'), (53, 53, 'EMP003', 'EMP001'), (54, 54, 'EMP003', 'EMP001'),
(55, 55, 'EMP003', 'EMP001'), (56, 56, 'EMP003', 'EMP001'), (57, 57, 'EMP003', 'EMP001'),
(58, 58, 'EMP003', 'EMP001'), (59, 59, 'EMP003', 'EMP001'), (60, 60, 'EMP003', 'EMP001'),
(61, 61, 'EMP003', 'EMP001'), (62, 62, 'EMP003', 'EMP001'), (63, 63, 'EMP003', 'EMP001'),
(64, 64, 'EMP003', 'EMP001'), (65, 65, 'EMP003', 'EMP001'), (66, 66, 'EMP003', 'EMP001'),
(67, 67, 'EMP003', 'EMP001'), (68, 68, 'EMP003', 'EMP001'), (69, 69, 'EMP003', 'EMP001'),
(70, 70, 'EMP003', 'EMP001');

-- =========================
-- 70 RECORDS FOR BUCKET_PLACEMENT
-- =========================
INSERT INTO Bucket_Placement (bucket_placement_id, bucket_id, warehouse_id, employee_id, bucket_placement_date) VALUES
(1, 1, 'WH001', 'EMP020', '2024-01-16'), (2, 2, 'WH002', 'EMP020', '2024-01-21'), (3, 3, 'WH003', 'EMP020', '2024-01-26'),
(4, 4, 'WH004', 'EMP020', '2024-02-02'), (5, 5, 'WH005', 'EMP020', '2024-02-06'), (6, 6, 'WH006', 'EMP020', '2024-02-11'),
(7, 7, 'WH007', 'EMP020', '2024-02-16'), (8, 8, 'WH008', 'EMP020', '2024-02-21'), (9, 9, 'WH009', 'EMP020', '2024-02-26'),
(10, 10, 'WH010', 'EMP020', '2024-03-02'), (11, 11, 'WH011', 'EMP020', '2024-03-06'), (12, 12, 'WH012', 'EMP020', '2024-03-11'),
(13, 13, 'WH013', 'EMP020', '2024-03-16'), (14, 14, 'WH014', 'EMP020', '2024-03-21'), (15, 15, 'WH015', 'EMP020', '2024-03-26'),
(16, 16, 'WH016', 'EMP020', '2024-04-02'), (17, 17, 'WH017', 'EMP020', '2024-04-06'), (18, 18, 'WH018', 'EMP020', '2024-04-11'),
(19, 19, 'WH019', 'EMP020', '2024-04-16'), (20, 20, 'WH020', 'EMP020', '2024-04-21'), (21, 21, 'WH021', 'EMP020', '2024-04-26'),
(22, 22, 'WH022', 'EMP020', '2024-05-02'), (23, 23, 'WH023', 'EMP020', '2024-05-06'), (24, 24, 'WH024', 'EMP020', '2024-05-11'),
(25, 25, 'WH025', 'EMP020', '2024-05-16'), (26, 1, 'WH026', 'EMP020', '2024-05-21'), (27, 2, 'WH027', 'EMP020', '2024-05-26'),
(28, 3, 'WH028', 'EMP020', '2024-06-02'), (29, 4, 'WH029', 'EMP020', '2024-06-06'), (30, 5, 'WH030', 'EMP020', '2024-06-11'),
(31, 6, 'WH031', 'EMP020', '2024-06-16'), (32, 7, 'WH032', 'EMP020', '2024-06-21'), (33, 8, 'WH033', 'EMP020', '2024-06-26'),
(34, 9, 'WH034', 'EMP020', '2024-07-02'), (35, 10, 'WH035', 'EMP020', '2024-07-06'), (36, 11, 'WH036', 'EMP020', '2024-07-11'),
(37, 12, 'WH037', 'EMP020', '2024-07-16'), (38, 13, 'WH038', 'EMP020', '2024-07-21'), (39, 14, 'WH039', 'EMP020', '2024-07-26'),
(40, 15, 'WH040', 'EMP020', '2024-08-02'), (41, 16, 'WH041', 'EMP020', '2024-08-06'), (42, 17, 'WH042', 'EMP020', '2024-08-11'),
(43, 18, 'WH043', 'EMP020', '2024-08-16'), (44, 19, 'WH044', 'EMP020', '2024-08-21'), (45, 20, 'WH045', 'EMP020', '2024-08-26'),
(46, 21, 'WH046', 'EMP020', '2024-09-02'), (47, 22, 'WH047', 'EMP020', '2024-09-06'), (48, 23, 'WH048', 'EMP020', '2024-09-11'),
(49, 24, 'WH049', 'EMP020', '2024-09-16'), (50, 25, 'WH050', 'EMP020', '2024-09-21'), (51, 1, 'WH051', 'EMP020', '2024-09-26'),
(52, 2, 'WH052', 'EMP020', '2024-10-02'), (53, 3, 'WH053', 'EMP020', '2024-10-06'), (54, 4, 'WH054', 'EMP020', '2024-10-11'),
(55, 5, 'WH055', 'EMP020', '2024-10-16'), (56, 6, 'WH056', 'EMP020', '2024-10-21'), (57, 7, 'WH057', 'EMP020', '2024-10-26'),
(58, 8, 'WH058', 'EMP020', '2024-11-02'), (59, 9, 'WH059', 'EMP020', '2024-11-06'), (60, 10, 'WH060', 'EMP020', '2024-11-11'),
(61, 11, 'WH061', 'EMP020', '2024-11-16'), (62, 12, 'WH062', 'EMP020', '2024-11-21'), (63, 13, 'WH063', 'EMP020', '2024-11-26'),
(64, 14, 'WH064', 'EMP020', '2024-12-02'), (65, 15, 'WH065', 'EMP020', '2024-12-06'), (66, 16, 'WH066', 'EMP020', '2024-12-11'),
(67, 17, 'WH067', 'EMP020', '2024-12-16'), (68, 18, 'WH068', 'EMP020', '2024-12-21'), (69, 19, 'WH069', 'EMP020', '2024-12-26'),
(70, 20, 'WH070', 'EMP020', '2024-12-31');

--reporing queries
select* from Bucket
select* from honey_batch
select* from Hive_Purchase

