/*
Cleaning Data in SQL Queries
*/

select * from [Nashville Housing]


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, convert(date, SaleDate) from [Nashville Housing]

update [Nashville Housing]
set SaleDate = convert(date, SaleDate)

-- If it doesn't Update properly

alter table [Nashville Housing]
add Sale_Date date

update [Nashville Housing]
set Sale_Date = convert(date, SaleDate)

select Sale_Date from [Nashville Housing]


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from [Nashville Housing]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing] a join [Nashville Housing] b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing] a join [Nashville Housing] b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from [Nashville Housing]

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from [Nashville Housing]

alter table [Nashville Housing]
add Property_Address nvarchar(255)

update [Nashville Housing]
set Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table [Nashville Housing]
add Property_City nvarchar(255)

update [Nashville Housing]
set Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select * from [Nashville Housing]


select OwnerAddress from [Nashville Housing]
where OwnerAddress is not null

select parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from [Nashville Housing]


alter table [Nashville Housing]
add Owner_Address nvarchar(255)

update [Nashville Housing]
set Owner_Address = parsename(replace(OwnerAddress, ',', '.'), 3)


alter table [Nashville Housing]
add Owner_City nvarchar(255)

update [Nashville Housing]
set Owner_City = parsename(replace(OwnerAddress, ',', '.'), 2)


alter table [Nashville Housing]
add Owner_State nvarchar(255)

update [Nashville Housing]
set Owner_State = parsename(replace(OwnerAddress, ',', '.'), 1)

select * from [Nashville Housing]


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant) 
from [Nashville Housing] 
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from [Nashville Housing]


update [Nashville Housing]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *,
       ROW_NUMBER() over(
	   partition by ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by
					UniqueID
					) row_num
from [Nashville Housing]
)
select * from RowNumCTE
where row_num > 1



select * from [Nashville Housing]


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select * from [Nashville Housing]

alter table [Nashville Housing]
drop column PropertyAddress, OwnerAddress, TaxDistrict

alter table [Nashville Housing]
drop column SaleDate
