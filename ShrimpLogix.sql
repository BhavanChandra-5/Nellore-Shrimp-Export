CREATE DATABASE shrimp_logix_db;
USE shrimp_logix_db;

-- 1. Farmers Table
CREATE TABLE farmers (
    farmer_id INT PRIMARY KEY AUTO_INCREMENT,
    farmer_name VARCHAR(100) NOT NULL,
    area VARCHAR(50), -- e.g., 'Indukurpet'
    phone VARCHAR(15)
);

-- 2. Harvest Table (Linking to Farmer)
CREATE TABLE harvests (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    farmer_id INT,
    shrimp_type ENUM('Vannamei', 'Tiger') DEFAULT 'Vannamei',
    total_weight_kg DECIMAL(10,2),
    harvest_date DATE,
    FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id)
);

-- 3. Export Orders (Linking to Harvest)
CREATE TABLE export_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_id INT,
    destination_country VARCHAR(50), -- e.g., 'USA', 'Japan'
    price_per_kg DECIMAL(10,2),
    shipping_status ENUM('Processing', 'Shipped', 'Delivered'),
    FOREIGN KEY (batch_id) REFERENCES harvests(batch_id)
);
select * from farmers;
select * from harvests;
select * from export_orders;

#Farmers Data (Adding 20 unique farmers across Nellore)
INSERT INTO farmers (farmer_name, area, phone) VALUES 
('Murali Krishna', 'Indukurpet', '9848012345'), ('Venkat Rao', 'Kavali', '9989054321'),
('Subba Reddy', 'Muthukur', '8123456789'), ('Prasad Rao', 'Allur', '7702233445'),
('Sivakumar', 'Kodavaluru', '9440011223'), ('Ramanaiah', 'Buchireddypalem', '9000112233'),
('Anjaneyulu', 'Sangam', '9123456780'), ('Krishnaiah', 'Vidhya Nagar', '9988776655'),
('Penchalaiah', 'Kovur', '9876543210'), ('Srinivasulu', 'Dagadarthi', '9550011224'),
('Raghava Reddy', 'Manubolu', '9441122334'), ('Chalapathi', 'Gudur', '9332233445'),
('Nageswara Rao', 'Podalakur', '9223344556'), ('Sudhakar', 'Venkatachalam', '9114455667'),
('Bhaskar', 'Kota', '9005566778'), ('Guravaiah', 'Vakadu', '8996677889'),
('Narayana', 'Chittamur', '8887788990'), ('Koteswara Rao', 'Sullurpeta', '8778899001'),
('Mohan Reddy', 'Tada', '8669900112'), ('Raja Gopal', 'Naidupeta', '8550011223');

#Harvests Data (100 batches linked to 20 farmers)
#Generating random weights between 500kg - 3000kg
#Tip: Run this multiple times if needed to fill up more data

INSERT INTO harvests (farmer_id, shrimp_type, total_weight_kg, harvest_date)
SELECT 
    (FLOOR(1 + RAND() * 20)), -- Random Farmer ID between 1-20
    IF(RAND() > 0.3, 'Vannamei', 'Tiger'), -- 70% Vannamei, 30% Tiger
    ROUND(500 + RAND() * 2500, 2), -- Weight between 500 and 3000
    DATE_ADD('2026-01-01', INTERVAL FLOOR(RAND() * 90) DAY) -- Random date in last 3 months
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) AS a,
     (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) AS b,
     (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) AS c;
     

#Export Orders Data (Linking 100 orders to 100 harvests)

INSERT INTO export_orders (batch_id, destination_country, price_per_kg, shipping_status)
SELECT 
    h.batch_id,
    ELT(FLOOR(1 + RAND() * 6), 'USA', 'Japan', 'Vietnam', 'China', 'Germany', 'UAE'), -- Random Countries
    IF(h.shrimp_type = 'Tiger', ROUND(900 + RAND() * 300, 2), ROUND(600 + RAND() * 250, 2)), -- Tiger is costlier
    ELT(FLOOR(1 + RAND() * 3), 'Processing', 'Shipped', 'Delivered')
FROM harvests h;

select * from farmers;
select * from harvests;
select * from export_orders;

SELECT destination_country, COUNT(*) as total_orders, SUM(total_weight_kg) as total_qty
FROM export_orders e
JOIN harvests h ON e.batch_id = h.batch_id
GROUP BY destination_country
ORDER BY total_qty DESC;

SELECT f.farmer_name, SUM(h.total_weight_kg * e.price_per_kg) as total_revenue
FROM farmers f
JOIN harvests h ON f.farmer_id = h.farmer_id
JOIN export_orders e ON h.batch_id = e.batch_id
GROUP BY f.farmer_name
ORDER BY total_revenue DESC LIMIT 5;

SELECT f.area, COUNT(*) as tiger_batches
FROM farmers f
JOIN harvests h ON f.farmer_id = h.farmer_id
WHERE h.shrimp_type = 'Tiger'
GROUP BY f.area;