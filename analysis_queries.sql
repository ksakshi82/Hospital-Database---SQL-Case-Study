CREATE DATABASE Hospital_D;

use Hospital_D;
select * from appointments;
select * from billing;
select * from doctors;
select * from patients;
select * from treatments;

DESCRIBE patients;
DESCRIBE doctors;
DESCRIBE appointments;
DESCRIBE treatments;
DESCRIBE billing;

-- Update Patients and Doctors
ALTER TABLE patients MODIFY patient_id VARCHAR(50);
ALTER TABLE doctors MODIFY doctor_id VARCHAR(50);

-- Update Appointments
ALTER TABLE appointments 
    MODIFY appointment_id VARCHAR(50), 
    MODIFY patient_id VARCHAR(50), 
    MODIFY doctor_id VARCHAR(50);

-- Update Treatments
ALTER TABLE treatments 
    MODIFY treatment_id VARCHAR(50), 
    MODIFY appointment_id VARCHAR(50);

-- Update Billing
ALTER TABLE billing 
    MODIFY bill_id VARCHAR(50), 
    MODIFY patient_id VARCHAR(50), 
    MODIFY treatment_id VARCHAR(50);
    
 -- Primary Key uniquely identifies each row in a table.
ALTER TABLE patients ADD PRIMARY KEY (patient_id);
ALTER TABLE doctors ADD PRIMARY KEY (doctor_id);
ALTER TABLE appointments ADD PRIMARY KEY (appointment_id);
ALTER TABLE treatments ADD PRIMARY KEY (treatment_id);
ALTER TABLE billing ADD PRIMARY KEY (bill_id);   

-- Link Appointments to Patients and Doctors
ALTER TABLE appointments 
    ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    ADD FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id);

-- Link Treatments to specific Appointments
ALTER TABLE treatments 
    ADD FOREIGN KEY (appointment_id) 
    REFERENCES appointments(appointment_id);

-- Link Billing to the Patient and the specific Treatment
ALTER TABLE billing 
    ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    ADD FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id);
    



-- 1️ Total Hospital Revenue
SELECT ROUND(SUM(amount),2) AS total_revenue
FROM billing;

-- 2 Monthly Revenue Trend
SELECT MONTH(bill_date) AS month,
       ROUND(SUM(amount),2) AS total_revenue
FROM billing
GROUP BY MONTH(bill_date)
ORDER BY month;

-- 3 Top Revenue-Generating Treatments
SELECT t.treatment_type,
       ROUND(SUM(b.amount),2) AS total_revenue
FROM treatments t
JOIN billing b ON t.treatment_id = b.treatment_id
GROUP BY t.treatment_type
ORDER BY total_revenue DESC;

-- 4 Revenue by Doctor
SELECT d.doctor_id,
       d.first_name,
       ROUND(SUM(b.amount),2) AS total_revenue
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
JOIN billing b ON t.treatment_id = b.treatment_id
GROUP BY d.doctor_id, d.first_name
ORDER BY total_revenue DESC;

-- 5 Revenue by Doctor & Specialization
SELECT d.specialization,
       d.doctor_id,
       ROUND(SUM(b.amount),2) AS total_revenue
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
JOIN billing b ON t.treatment_id = b.treatment_id
GROUP BY d.specialization, d.doctor_id
ORDER BY total_revenue DESC;


-- 6️ Payment Status Distribution
SELECT payment_status,
       COUNT(*) AS total_transactions,
       ROUND(SUM(amount),2) AS total_amount
FROM billing
GROUP BY payment_status;

-- 7 Outstanding Accounts Receivable
SELECT ROUND(SUM(amount),2) AS outstanding_amount
FROM billing
WHERE payment_status IN ('Pending','Failed');

-- 8 Most Used Payment Method
SELECT payment_method,
       COUNT(*) AS total_transactions
FROM billing
GROUP BY payment_method
ORDER BY total_transactions DESC;

-- 9️ Total Appointments Per Doctor
SELECT doctor_id,
       COUNT(*) AS total_appointments
FROM appointments
GROUP BY doctor_id
ORDER BY total_appointments DESC;

-- 10 Rank Doctors by Revenue
SELECT d.doctor_id,
       d.first_name,
       SUM(b.amount) AS total_revenue,
       RANK() OVER (ORDER BY SUM(b.amount) DESC) AS revenue_rank
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
JOIN billing b ON t.treatment_id = b.treatment_id
GROUP BY d.doctor_id, d.first_name;

-- 11 Doctors With No Appointments
SELECT d.doctor_id, d.first_name
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
WHERE a.appointment_id IS NULL;

-- 12 High-Visit Patients (Retention Indicator)
SELECT patient_id,
       COUNT(*) AS total_visits
FROM appointments
GROUP BY patient_id
HAVING COUNT(*) > 5;

-- 13 Insurance Provider Revenue Contribution
SELECT p.insurance_provider,
       COUNT(DISTINCT p.patient_id) AS total_patients,
       ROUND(SUM(b.amount),2) AS total_revenue
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN treatments t ON a.appointment_id = t.appointment_id
JOIN billing b ON t.treatment_id = b.treatment_id
GROUP BY p.insurance_provider
ORDER BY total_revenue DESC;


-- 14 Cancellation Count
SELECT COUNT(*) AS cancelled_appointments
FROM appointments
WHERE status = 'Cancelled';

-- 15 The Cost of No-Shows and Cancellations
SELECT 
    COUNT(*) AS cancelled_appointments,
    SUM(t.cost) AS estimated_revenue_loss
FROM appointments a
JOIN treatments t ON a.appointment_id = t.appointment_id
WHERE a.status = 'Cancelled';

-- Doctors With More Than 20 Years Experience
SELECT doctor_id, first_name, years_experience
FROM doctors
WHERE years_experience > 20
ORDER BY years_experience DESC;

-- Doctor Experience Category
SELECT doctor_id,
       first_name,
       CASE
           WHEN years_experience >= 25 THEN 'Senior'
           WHEN years_experience >= 10 THEN 'Mid-Level'
           ELSE 'Junior'
       END AS experience_level
FROM doctors;

-- Patients With More Than 5 Appointment
SELECT patient_id,COUNT(*) AS total_visits
FROM appointments
GROUP BY patient_id HAVING COUNT(*) > 5 limit 3 ;


          
