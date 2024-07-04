
-- Add project to portfolio


-- Data Cleaning: Is getting the data in a more usable format to  fix alot of the issues in the raw data 
-- so that when you start creating  visualizations or start using in your products that the data is actualy useful and there arent alot of issues with it

-- Creating data base: click on a new data base at the top left, name the new database, click apply, finish. 
-- Importing a data: 
-- 1. Now you will see the data "world_layoffs" 
-- 2. Click the drop down in "world_tables", 
-- 3. right click Tbales, 
-- 4. click Table data import wizard
-- 5. click brows and open the excel table that you have downloaded
-- 6. click next
-- 7. pick "create new table" and check "drop table if exists"
-- 8. click next
-- 9. In configure Import table settings you are able change field type or leave it and click next but in this case leave it and click next
-- 10. Click next to import table
-- 11. once table is don uploading click next
-- Click finish
-- Exit "world_layoffs" - schema tab at the top 
-- Refresh in the top right of schema field
-- Now you have a table drop down in "World_layoffs" data base
-- click on table drop down in data base and you will see "layoffs" table


-- You can now pull up the table of World_layoff data base
-- Query below returns layoffs table data

Select *
From layoffs
;

-- 1. Remove duplicates
-- 2. Standerdize the data
-- 3. Remove Null values or blank values
-- 4. Remove any columns or rows that are not necessary

-- This squery will create the new table layoffs_staging and return the same columns as layoffs
-- You will see this new layoffs_staging table right under the world_layofffs data base after you refresh in navigator
-- This isthe first step to transfer all the data from the raw layoffs table to the new layoffs_staging table

Create table layoffs_staging
Like layoffs
;


-- Qyuery will now return layoffs_staging

Select *
From layoffs_staging
;



-- This will insert all the data from layoffs table into layoffs_stagging table
-- We are creating the layoffs_stagging table so that if we make any mistakes in it we will always have the raw layoffs table
-- Never use a raw data table

Insert layofs_staging
Select *
From layoffs
;




-- Removing duplicates

-- This query returns your table to look for duplicate data

Select * 
From layofs_staging
;


-- Query will return all the row numbers as 1

Select * 
Row_number() over(
Partition by company, industry, total_laid_off, percentage_laid_off, 'data') As row_num
From layoffs_stagging
;


-- CTE query
-- Query will return all the duplicate data
-- All duplicate rows will have row_number 2

With duplicate_cte AS 
(
Select *, 
Row_number() over(
Partition by company, location, 
industry, total_laid_off, percentage_laid_off, 'date', stage
, country, funds_raised_millions) As row_num
From layoffs_staging
)
Select *
From duplicate_cte
Where row_num > 1; 



-- Query will return a row with duplicating data from casper "company"
-- We will only remove one row because only one row is the exact duplicate as the other

Select * 
From layoffs_staging
Where company = 'Casper'
;



-- You cant update a CTE. A delete statement is like an update

With duplicate_cte AS 
(
Select *, 
Row_number() over(
Partition by company, location, 
industry, total_laid_off, percentage_laid_off, 'date', stage
, country, funds_raised_millions) As row_num
From layoffs_staging
)
Delete
From duplicate_cte
Where row_num > 1; 




-- You can return the query of an already cretaed table by right clicking on a table, click copy to clipboard, click create statement then past it
-- Change the name to "layoffs_staging 2" to create a new table 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- Now when you run this query iy will return the new tables columns

Select *
From layoffs_staging2
;



-- Query will insert data from original layoffs_staging table

Insert into layoffs_staging2
Select *,
Row_number() Over(
Partition by company, location,
Industry, total_laid_off, percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
From layoffs_staging 
;


-- This query will return all the the new data inserted into "layoffs_staging2" from "layoffs_staging

Select *
From layoffs_staging2
;



-- Query will return all the rows that are greater than 1 and duplicating

Select *
From layoffs_staging2
Where row_num > 1
;


-- Query will delet all the rows with numbers greater than 1 thats duplicating
-- If this query doesnt work then go to edit at top left, click prefrences, click SQL editer, unselect safe updates then click okay.  
-- You will now be able to run the delete query

Delete
From layoffs_staging2
Where row_num > 1
;



-- Query will return a blank table because all duplicate row_num will be deleted

select *
From layoffs_staging2
Where row_num > 1
;



-- Now query will return the table with no duplicating data

Select *
From layoffs_staging2
;



-- Standerdizing data: finding issues in your data and fixing it
-- EX of standerdizing data could be a data that has an extra word that does not match with the other data in that column - Like if industry column has "crypto" but somewhere in that calumn it has 2 or 3 "crypto currancy" 
-- Then you can fix the issue with the below querys
-- Standerdizing basically fixes how some data in columns have been typed/worded


-- Query will return only company column data

Select Distinct  Distinct(trim(company))
From layoffs_staging2
;


-- This query returns 2 company columns

Select company, trim(company)
From layoffs_staging2
;



-- Trim: takes off the white space off the end of a column name

Update layoffs_staging2
Set company = trim(company)
;


-- This query will retrun the individual industry column and show that crypto currency is repeated. Crypto currency shouldt be repeated beacue it is the same thing
-- Also have blank industry data under the industry column that we can fix later

Select distinct industry
From layoffs_staging2
order by 1
;




-- Query will return all the lay offs in the crypto currency

Select *
From layoffs_staging2
Where industry like 'Crypto%' ;
;


-- Query wil change some of the industry named crypto currancy to just crypto

update layoffs_staging2
Set industry = 'crypto' 
Where industry Like 'crypto%'
;



-- Now if you scrol down all industry is called crypto instead of crypto currancy


Select *
From layoffs_staging2
Where industry like 'Crypto%'
;



-- Query returns only industry column with indivul industries

Select Distinct industry
From layoffs_staging2
;



-- Query will return location column to see if there are any issues within thst column

Select distinct location
From layoffs_staging2
Order by 1
;


-- Query will return the column data in country and help you find which data in the column that added an extra word or symble that does not belong
-- EX there are two united states in this column but one of them has a period at the end. We will remove the period at the end because it doesnt fit and not normal

Select distinct country
From layoffs_staging2
Order by 1
;



-- Query pulls up all data with country column of "united states"

Select *
From layoffs_staging2
Where country like 'united states%'
Order by 1
;




-- Query will temp remove the period at the end of the "united stats" that had a period and compare united states. and united states side by side
-- Trim and specifying what you want to trim like the period will remove it

Select distinct country, trim(trailing '.' from country)
From layoffs_staging2
Order by 1
;


-- Query will update united states by taking away the period in country column and just having it in one row


Update layoffs_staging2
Set country = Trim(Trailing '.' From country)
Where country like 'united states%'
;



-- Now run this  query again it will show the update to "united states" with the period gone in country column

Select distinct country, trim(trailing '.' from country)
From layoffs_staging2
Order by 1
;



-- This query will temp convert the date into the standered date format by comparing standered date and text date side by side
-- EXP: of standerd date format is 2024-06-15
-- Keep the format in m/d/Y to have it best organized in standereddate format. Make sure the year is capitilized in the query

Select `date`,
From layoffs_staging2
;



-- Query will update the date into standered format
-- !! Try query again because it did not work

Update layoffs_staging2
Set `date` = Str_to_date(`date`, '%m/%d/%Y')
;



-- Query will return date into standered format
-- !! This query is not working for some reason so retry 

Select `date`,
From layoffs_staging2
;


-- Query will change the data type so for this it will modify date to a date column
-- If you refresh and click on date the column at the buttom will say "date"

Alter table layoffs_staging2
Modify column `date` Date;




-- Query will return your staging2 table with all the changes you have made to it

Select *
From layoffs_staging2
;




-- Null and blank values


-- Query will return total laid off culmns with null data to fix data

Select *
From layoffs_staging2
Where total_laid_off is null
And percentage_laid_off is null;



-- Check to see if you have a missing value and a null in staging 2 table

Select Distinct industry
From layoffs_staging2
;



-- Query will return the null and missing value in industry column

Select Distinct industry
From layoffs_staging2
Where industry is null
Or Industry = ''
;


-- Query will return all data where airbnb shows null

Select *
From layoffs_staging2
Where company = 'Airbnb'
;




-- Query will return industry thats null or blank and industry that is not null

Select *
From layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company = t2.company
    And t1.location = t2. location
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null
;


-- Query will justy return the 2 layoffstaging tables with industry data showing no values or nulls
-- This will also help you to figure out what you needto update in your next query below to fill out the blank values

Select t1.industry, t2.industry
From layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company = t2.company
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null
;


-- Query we are filling in where the stagung 2 t1 table is null or blank and where t2 is not null

Update layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company = t2.company
Set t1. industry = t2.industry
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null
;




-- Check to see if update worked
-- This did not work but Alex is figuring out why

Select t1.industry, t2.industry
From layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company = t2.company
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null
;


-- Query will change industry to null where its blank 

Update layoffs_staging2
Set Industry = null
Where industry = '';



-- Now Query will return table with no blanks and now it will have nulls on t1 table
-- Looks like the issue has now been resolved from the first attempt at the top
-- now lets try to update the tables again

Select t1.industry, t2.industry
From layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company = t2.company
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null
;



-- Query will update to fill in where the staging 2 t1 table is null or blank and where t2 is not null
-- Will show 3 rows affected

Update layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company = t2.company
Set t1. industry = t2.industry
Where t1.industry is null
And t2.industry is not null
;



-- Query will return nothing because it has gotten rid of the null and blank values because they are not needed in a table

Select t1.industry, t2.industry
From layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company = t2.company
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null
;



-- Now we can see that airbnb indsurty is now filled with "travel" instead of it being blank or null earlier

Select *
From layoffs_staging2
Where company = 'Airbnb'
;



-- Will show that company "Ballys" is the only one who has a null in indusrty and total laid off
-- Next we will look up ballys to fix the nulls issue

Select Distinct *
From layoffs_staging2
Where industry is null
Or Industry = ''
;


-- Query should retrun only one row that has null in industry and total laid off and thats fine
-- My query returns 5 ballys with null at industry and total laid off but I believe its because I should remove those duplicates on my own if I want to

Select *
From layoffs_staging2
Where company Like 'Bally%'
;


 -- Query returns the staging 2 data after all the query updates that were made for null and blank values

Select *
From layoffs_staging2
;



-- Return table whwhere total laid off and percentage laid off shows null so you know which null data to remove

Select *
From layoffs_staging2
Where total_laid_off is null
And percentage_laid_off is null
;


-- Query will deleted the total laid off and percentage laid off where its null

Delete
From layoffs_staging2
Where total_laid_off is null
And percentage_laid_off is null
;



-- Now if you returm the table it will be blank because total laid off and percentage laid off that had null has been removed

Select *
From layoffs_staging2
Where total_laid_off is null
And percentage_laid_off is null
;





-- returns table with all data and pick which columb you would like to drop 

Select *
From layoffs_staging2
;



-- Query will drop column

Alter Table layoffs_staging2
Drop Column row_num
;



-- When yuou return staging2 table it will no longer show row_num

Select *
From layoffs_staging2
;