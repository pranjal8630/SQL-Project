-- Schema LOGISTICS
-- ---------------------
create database Logistics;              # Creating a new database
use Logistics;                          # Using the newly created database 'LOGISTICS'

-- Table Employee details
-- ----------------------
create table if not exists Employee_Details(            # Creating a new table EMPLOYEE_Details
Emp_ID int(5) not null,
Emp_NAME varchar(30) null,
Emp_BRANCH varchar(15) null,
Emp_DESIGNATION varchar(40) null,
Emp_ADDR varchar(100) null,
Emp_CONT_NO varchar(10) null,
primary key(Emp_ID)
);


-- Table Membership
-- ----------------
create table if not exists Membership(               # Creating a new table MEMBERSHIP
M_ID INT NOT NULL,
START_DATE TEXT NULL,
END_DATE TEXT NULL,
primary key(M_ID)
);


-- Table Customer 
-- --------------
create table if not exists Customer(                   # Creating a new table Customer
Cust_ID INT(4) NOT NULL,
Cust_Name VARCHAR(30) NULL,
Cust_Email_ID VARCHAR(50) NULL,
Cust_Cont_NO VARCHAR(10) NULL,
Cust_addr VARCHAR(100) NULL,
Cust_Type VARCHAR(30) NULL,
Membership_M_ID INT NOT NULL,
PRIMARY KEY(Cust_ID, Membership_M_ID),
FOREIGN KEY(Membership_M_ID) 
REFERENCES membership(M_ID)
);


-- Table Shipment_Details
-- -----------------------
create table if not exists Shipment_Details(            # Creating a new table SHIPMENT_Details
Sd_ID VARCHAR(6) NOT NULL,
Sd_Content VARCHAR(40) NULL,
Sd_Domain VARCHAR(15) NULL,
Sd_Type VARCHAR(15) NULL,
Sd_Weight VARCHAR(10) NULL,
Sd_charges INT(10) NULL,
Sd_addr VARCHAR(100) NULL,
Ds_addr VARCHAR(100) NULL,
Customer_Cust_ID INT(4) NOT NULL,
PRIMARY KEY (Sd_ID, Customer_Cust_ID),
FOREIGN KEY (Customer_Cust_ID)
REFERENCES Customer (Cust_ID)
);


-- Table Payment_Details
-- ----------------------
create table if not exists Payment_Details(                    # Creating a new table PAYMENT_Details
Payment_ID VARCHAR(40) NOT NULL,
Amount INT NULL,
Payment_Status VARCHAR(10) NULL,
Payment_Date TEXT NULL,
Payment_Mode VARCHAR(25) NULL,
Shipment_Sh_ID VARCHAR(6) NOT NULL,
Shipment_Client_C_ID INT(4) NOT NULL,
PRIMARY KEY (Payment_ID, Shipment_Sh_ID, Shipment_Client_C_ID),

FOREIGN KEY (Shipment_Sh_ID,  Shipment_Client_C_ID)
REFERENCES Shipment_Details (Sd_ID, Customer_Cust_ID)
);


-- Table Status
-- ------------
create table if not exists Status(                                 # Creating a new table STATUS
Current_ST VARCHAR(15) NOT NULL,
Sent_Date TEXT NULL,
Delivery_Date TEXT NULL,
Sh_ID VARCHAR(6) NOT NULL,
PRIMARY KEY  (Sh_ID)
);


-- Table Employee_Manages_Shipment
-- -------------------------------
create table if not exists Employee_Manages_Shipment(                   # Creating a new table Employee_Manages_Shipment 
Employee_E_ID INT(5) NOT NULL,
Shipment_Sh_ID VARCHAR(6) NOT NULL,
Status_Sh_ID VARCHAR(6) NOT NULL,
PRIMARY KEY (Employee_E_ID, Shipment_Sh_ID, Status_Sh_ID),

FOREIGN KEY (Employee_E_ID)
    REFERENCES Employee_Details (Emp_ID),
    FOREIGN KEY (Shipment_Sh_id)
    REFERENCES Shipment_Details (Sd_id),
    FOREIGN KEY (Status_Sh_id)
    REFERENCES Status (Sh_id)
);


DESCRIBE Customer;
DESCRIBE Employee_Details;
DESCRIBE Shipment_Details;
DESCRIBE Payment_Details;
DESCRIBE Membership;
DESCRIBE STATUS;
DESCRIBE employee_manages_shipment;


SELECT * FROM Employee_Details;
SELECT * FROM Membership;
SELECT * FROM Customer;
SELECT * FROM Payment_Details;
SELECT * FROM Shipment_Details;
SELECT * FROM logistics.status;
SELECT * FROM employee_manages_shipment;


# 1) Find the incorrect dates in the 'STATUS' table from the 'DELIVERY DATE' column, where the month is greater than 12.
SELECT DELIVERY_DATE FROM STATUS 
	WHERE CAST(substring_index(DELIVERY_DATE, '/', 1) AS UNSIGNED) > 12;


# 2) Search for the records where the month is February but the date is incorrectly entered as 30 and 31.
SELECT * FROM STATUS 
	WHERE CAST(substring_index(DELIVERY_DATE, '/', 1) AS UNSIGNED) = 2 
		AND 
	CAST(substring_index(substring_index(DELIVERY_DATE, '/', 2), '/', -1) AS UNSIGNED)  > 29;
SELECT * FROM STATUS 
	WHERE CAST(substring_index(SENT_DATE, '/', 1) AS UNSIGNED) = 2 
		AND 
	CAST(substring_index(substring_index(SENT_DATE, '/', 2), '/', -1) AS UNSIGNED)  > 29;
SELECT * FROM Payment_Details
	WHERE CAST(substring_index(substring_index(PAYMENT_DATE, '-', 2), '-', -1) AS UNSIGNED) = 2 
		AND 
    CAST(substring_index(PAYMENT_DATE, '-', -1) AS UNSIGNED) > 29;
    


-- Converting the string in to a date format
-- -----------------------------------------------------
UPDATE Payment_Details
	SET Payment_Date = STR_TO_DATE(Payment_Date,'%Y-%m-%d');    
UPDATE STATUS
	SET Delivery_Date = STR_TO_DATE(Delivery_Date,'%m/%d/%Y'),
    Sent_Date = STR_TO_DATE(Sent_Date,'%m/%d/%Y');
UPDATE MEMBERSHIP
	SET Start_Date = STR_TO_DATE(Start_Date,'%Y-%m-%d'),
    End_Date = STR_TO_DATE(End_Date,'%Y-%m-%d');




-- Changing the datatype from TEXT to DATE
-- -----------------------------------------------------
ALTER TABLE Payment_Details
	MODIFY COLUMN Payment_Date Date;
ALTER TABLE STATUS
	MODIFY COLUMN Delivery_Date Date, MODIFY COLUMN Sent_Date Date ;
ALTER TABLE MEMBERSHIP
	MODIFY COLUMN Start_Date Date, MODIFY COLUMN End_Date Date ;




-- Creating a Single Source Of Truth (SSOT)
-- -----------------------------------------------------
CREATE TABLE logistics_Emp AS
SELECT 
	emp.Emp_ID, ship.SD_ID, Cust.Cust_ID, pmt.Payment_ID, memb.M_ID,
    emp.Emp_NAME, emp.Emp_ADDR, emp.Emp_BRANCH, emp.Emp_DESIGNATION, emp.Emp_CONT_NO,
    ship.Sd_Domain, ship.Sd_Content, ship.Sd_addr, ship.Ds_addr, ship.Sd_Weight, ship.Sd_Type, ship.Sd_Charges,
    cust.Cust_Name, cust.Cust_Type, cust.Cust_addr, cust.Cust_Cont_NO, cust.Cust_Email_ID,
    stat.Sent_Date, stat.Delivery_Date, stat.Current_ST, 
    pmt.Amount, pmt.Payment_Status, pmt.Payment_Date, pmt.Payment_Mode,
    memb.Start_Date, memb.End_Date
FROM
    EMPLOYEE_Details AS emp
         INNER JOIN
	employee_manages_shipment AS ems ON emp.Emp_ID = ems.Employee_deatils_Emp_ID
         INNER JOIN
    SHIPMENT_Details AS ship ON ship.SH_ID = ems.Shipment_SH_ID
		 INNER JOIN
	Customer AS cust ON Cust.C_ID = ship.Customer_Cust_ID
		 INNER JOIN
	STATUS AS stat ON ship.SH_ID = stat.SH_ID
		 INNER JOIN
	PAYMENT AS pmt ON ship.SH_ID = pmt.Shipment_SH_ID
		 INNER JOIN
	MEMBERSHIP AS memb ON memb.M_ID = cust.Membership_M_ID;
 
select * from logistics_Emp;





# ----------------------------------------------------------- TASKS -----------------------------------------------------------

# 3) Extract all the employees whose name starts with A and ends with A.
SELECT Emp_name FROM Employee_Deatils WHERE Emp_name LIKE 'A%A';

# 4) Find all the common names from Employee_Details names and Customer names.
SELECT DISTINCT(Emp_name) FROM Employee_Details WHERE Emp_name IN (SELECT Cust_name FROM Customer AS cus);


# 5) Create a view 'PaymentNotDone' of those customers who have not paid the amount.
CREATE VIEW PaymentNotDone AS
SELECT * FROM logistics_Emp
WHERE PAYMENT_STATUS = 'NOT PAID';

-- Selecting all the observations of the newly created view 'PaymentNotDone'
SELECT * FROM PaymentNotDone;

# 6) Find the frequency (in percentage) of each of the class of the payment mode
SET @total_count = 0;
SELECT COUNT(*) INTO @total_count FROM Payment_Deatils;
SELECT 
    PAYMENT_MODE,
    ROUND((COUNT(PAYMENT_MODE) / @total_count) * 100,2) 
		AS Percentage_Contribution
FROM
    Payment_Details
GROUP BY PAYMENT_MODE;

# 7) Create a new column 'Total_Payable_Charges' using shipping cost and price of the product.
ALTER TABLE logistics_Emp
	ADD COLUMN TOTAL_PAYABLE_CHARGES FLOAT AFTER AMOUNT;

UPDATE logistics_Emp 
	SET TOTAL_PAYABLE_CHARGES = Sh_Charges + Amount;
SELECT TOTAL_PAYABLE_CHARGES FROM logistics_Emp;

# 8) What is the highest total payable amount ?
SELECT MAX(TOTAL_PAYABLE_CHARGES) FROM logistics_Emp;


# 9) Extract the customer id and the customer name  of the customers who were or will be the member of the branch for more than 10 years
SELECT Cust_ID, Cust_NAME, START_DATE, END_DATE, ROUND(DATEDIFF(END_DATE, START_DATE)/365,0) 
	AS Membership_Years FROM logistics_Emp 
HAVING Membership_Years > 10;


# 10) Who got the product delivered on the next day the product was sent?
SELECT * FROM logistics_Emp 
	HAVING DELIVERY_DATE_SENT_DATE = 1;
SELECT * FROM logistics_Emp 
	HAVING DATEDIFF(DELIVERY_DATE, SENT_DATE)=1;

# 11) Which shipping content had the highest total amount (Top 5).
SELECT 
    SH_CONTENT, SUM(AMOUNT) AS Content_Wise_Amount
FROM
    logistics_Emp
GROUP BY (SH_CONTENT)
ORDER BY Content_Wise_Amount DESC
LIMIT 5;

# 12) Which product categories from shipment content are transferred more?  
SELECT SH_CONTENT, COUNT(SH_CONTENT) 
	AS Content_Wise_Count 
FROM logistics_Emp 
GROUP BY(SH_CONTENT) 
ORDER BY Content_Wise_Count DESC 
LIMIT 5;

# 13) Create a new view 'TXLogistics' where employee branch is Texas.
CREATE VIEW TXLogistics AS
	SELECT * FROM logistics_Emp 
		WHERE E_BRANCH = 'TX';

SELECT * FROM TXLogistics;


# 14) Texas(TX) branch is giving 5% discount on total payable amount. Create a new column 'New_Price' for payable price after applying discount.
ALTER VIEW TXLogistics
   AS SELECT *, AMOUNT - ((AMOUNT * 5)/100) AS New_Price 
   FROM logistics_Emp
   WHERE E_BRANCH = 'TX';
SELECT * FROM TXLogistics;
   
   
# 15) Drop the view TXLogistics
DROP VIEW TXLogistics;


# 16) The employee branch in New York (NY) is shutdown temporarily. Thus, the the branch needs to be replaced to New Jersy (NJ).
SELECT * FROM logistics_Emp WHERE E_BRANCH = 'NY';

UPDATE logistics_Emp
	SET E_BRANCH = 'NJ'
WHERE E_BRANCH = 'NY';

SELECT * FROM logistics_Emp;

# 17) Finding the unique designations of the employees.
SELECT DISTINCT(Emp_DESIGNATION) FROM Employee_Details;

# 18) We will see the frequency of each customer type (in percentage).
SET @total_count = 0;
SELECT COUNT(*) INTO @total_count FROM logistics_Emp;
SELECT Cust_TYPE, (COUNT(Cust_TYPE)/@total_count)*100 
	AS Contribution FROM logistics_Emp 
GROUP BY Cust_TYPE;

# 19) Rename the column SER_TYPE to SERVICE_TYPE.
ALTER TABLE logistics_Emp
CHANGE SER_TYPE SERVICE_TYPE VARCHAR (15);

# 20) Which service type is preferred more?
SELECT SERVICE_TYPE, COUNT(SERVICE_TYPE) 
	AS Frequency 
FROM logistics_Emp 
GROUP BY SERVICE_TYPE 
ORDER BY Frequency DESC;

# 21) Find the shipment id and shipment content where the weight is greater than the average weight.
SELECT SH_ID, SH_CONTENT, SH_WEIGHT FROM Shipment_Details
WHERE SH_WEIGHT > (SELECT AVG(SH_WEIGHT) FROM Shipment_Details);





