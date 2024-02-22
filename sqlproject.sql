-- creating database schema 
create database sqlProject;

-- Modifying the data types of table columns and adding primary key constraint
select * from employee_details;
alter table employee_details modify E_NAME varchar(30) ;
alter table employee_details modify E_ID int primary key ;
alter table employee_details modify E_BRANCH varchar(15), 
modify E_DESIGNATION varchar(40),
modify E_ADDR varchar(100),
modify E_CONT_NO varchar(10) ;

-- Modifying the data types of table columns and adding primary key and foreign key constraint 
alter table customer 
modify C_NAME varchar(30),
modify C_EMAIL_ID varchar(50),
modify C_TYPE varchar(30),
modify C_ADDR varchar(100),
modify C_CONT_NO varchar(10);
alter table customer add primary key (C_ID); 
alter table customer add foreign key(M_ID) references membership(M_ID);

select * from payment_details;
-- Adding primary key constraint in the membership table
alter table membership add primary key (M_ID);

-- Modifying the data types of table columns and adding primary key and foreign key constraint
alter table payment_details 
modify Payment_ID varchar(40),
modify Payment_Status varchar(10),
modify Payment_Mode varchar(25),
modify SH_ID varchar(6);
alter table payment_details add primary key (Payment_ID);
alter table payment_details add foreign key(C_ID) references customer(C_ID);
alter table payment_details add foreign key(SH_ID) references shipment_details(SH_ID);

-- Modifying the data types of table columns and adding primary key and foreign key constraint
alter table shipment_details
modify SH_ID varchar(6) primary key,
modify SH_CONTENT varchar(40),
modify SH_DOMAIN varchar(15),
modify SER_TYPE varchar(15),
modify SH_WEIGHT varchar(10),
modify SR_ADDR varchar(100),
modify DS_ADDR varchar(100);
alter table shipment_details add foreign key(C_ID) references customer(C_ID);

-- Modifying the data types of table columns and adding primary key constraint
alter table status
modify Current_Status varchar(15),
modify SH_ID varchar(6);
alter table status add primary key(SH_ID);

-- Modifying the data types of table columns and adding foreign key constraint
alter table employee_manages_shipment
modify Shipment_Sh_ID varchar(6),
modify Status_Sh_ID varchar(6);
alter table employee_manages_shipment add foreign key(Employee_E_ID) references employee_details(E_ID);
alter table employee_manages_shipment add foreign key(Shipment_Sh_ID) references shipment_details(SH_ID);
alter table employee_manages_shipment add foreign key(Status_Sh_ID) references status(SH_ID);



