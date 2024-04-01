--Datacleanning using sql queries

--skills used joins,CTEs,window functions,Aggregate functions

select * from PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------
--Standardize the SaleDate

select SaleDateConverted, CONVERT(date,SaleDate) from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)

Alter table nashvillehousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted=CONVERT(date,SaleDate)

------------------------------------------------------------------------------------------------------------------

--populate property address data

select * from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a 
set a.PropertyAddress=ISNULL(a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------
--Breaking the addresss into individual columns(Address,city, state)

select PropertyAddress from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID

select SUBSTRING(propertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress))as address

from PortfolioProject.dbo.NashvilleHousing

Alter table nashvillehousing
add propertysplitaddress varchar(255)

update NashvilleHousing
set propertysplitaddress=SUBSTRING(propertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table nashvillehousing
add propertysplitcity varchar(255)

update NashvilleHousing
set propertysplitcity=SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress))

select * from NashvilleHousing

select
PARSENAME(replace(owneraddress,',','.'),3)
,PARSENAME(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)

from NashvilleHousing

Alter table nashvillehousing
add ownersplitaddress varchar(255)

update NashvilleHousing
set ownersplitaddress=PARSENAME(replace(owneraddress,',','.'),3)

Alter table nashvillehousing
add ownersplitcity varchar(255)

update NashvilleHousing
set ownersplitcity=PARSENAME(replace(owneraddress,',','.'),2)

Alter table nashvillehousing
add ownersplitstate varchar(255)

update NashvilleHousing
set ownersplitstate=PARSENAME(replace(owneraddress,',','.'),1)

select * from NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------

--change Y and N to yes and no in "sold as vacant "field

select distinct(SoldAsVacant),count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case
when SoldAsVacant='Y' then 'Yes'
 when SoldAsVacant='N' then 'No'
 else SoldAsVacant
 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant=case
when SoldAsVacant='Y' then 'Yes'
 when SoldAsVacant='N' then 'No'
 else SoldAsVacant
 end
 ---------------------------------------------------------------------------------------------------------------------------------

 --remove duplicates

 with row_numCTE as (
 select *,
 ROW_NUMBER() over(
 partition by parcelID,propertyAddress,
 saleprice,saledate,
 LegalReference
 order by uniqueID) row_num
 from NashvilleHousing
 --order by ParcelID
 )

  select *  from row_numCTE
 where row_num>1
 ---order by ParcelID

 ---------------------------------------------------------------------------------------------------------------------------------

 --delete unused columns

 select * from NashvilleHousing

 alter table NashvilleHousing
drop column owneraddress,taxdistrict,propertyaddress

alter table NashvilleHousing
drop column saledate