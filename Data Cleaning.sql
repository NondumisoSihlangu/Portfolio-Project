-- Data Cleaning & Standardization 

select * 
from NashvilleHousing


---------------------------------------------------------------------------------

--Standardize Date format to remove the Timestamp and appear just as the Date


Alter Table NashvilleHousing
Add SaleDates Date;

Update NashvilleHousing
Set SaleDates = cast(SaleDate as Date) 

--Added a new SaleDates column and input the converted SaleDate column data into it


----------------------------------------------------------------------------------

--Populate Property Address
--There are PropertyAddress fields that do not contain an address and the ParcelID is unique to each address. 
--We can use the PropertyID to fill in the PropertyAddress fields that are empty 
--Join the table to itself to retrieve nulls

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
JOIN NashvilleHousing as b 
on a.ParcelID = b.ParcelID and 
a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
JOIN NashvilleHousing as b 
on a.ParcelID = b.ParcelID and 
a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------

--Separate Address column into multiple columns 
--Separate values using a comma delimiter 
--Use CHARINDEX and remove the comma from the results using -1
--Start from the comma and extract everything after it, leave it out using +1
--Alter the table to add the newly created columns 

select PropertyAddress
from NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address2
from NashvilleHousing

Alter Table NashvilleHousing
Add StreetAddress Nvarchar(255);

Update NashvilleHousing
Set StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add City Nvarchar(255);

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 


--Do the same for OwnerAddress but using PARSENAME

select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from NashvilleHousing

--Add the new columns into the table 

Alter Table NashvilleHousing
Add OwnerStreetAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) 

Alter Table NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) 

Alter Table NashvilleHousing
Add OwnerStateAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) 




--------------------------------------------------------------------------------

--Change the Y and N to Yes and No in the Sold as Vacant column (some fields have Yes & No, some just have N and Y)
--First count how many of each Yes, Y, No, and N exist 


select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
Group By SoldAsVacant
Order By 2

--Replace the values 

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing

--Update the table 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end



-------------------------------------------------------------------------------------

--Remove Duplicates 
--Create a temp table and store all the duplicates in it
--Delete all the duplicates in the main table  

With Row_NumCTE AS (
select *, 
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID ) row_num
from NashvilleHousing
)
select * 
from Row_NumCTE
where row_num > 1
order by PropertyAddress





--------------------------------------------------------------------------------------

--Delete Unused Columns (like the ones that had full addresses and were split into different columns and date column that had the timestamp)



ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict