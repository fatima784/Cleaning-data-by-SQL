/****** Script for SelectTopNRows command from SSMS  ******/

--PROJECT 3
--CLEANING DATA IN SQL QUERIES


SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  select *from PortfolioProject.dbo.NashvilleHousing
-------------------------------------------------------------------------------
  ----1 Standardize Date Format

   select SaleDate, convert(Date, SaleDate)
   from PortfolioProject.dbo.NashvilleHousing

   update NashvilleHousing
   set SaleDate = convert(Date, SaleDate)

   --it didnt work so we use this

   select SaleDateConverted, convert(Date, SaleDate)
   from PortfolioProject.dbo.NashvilleHousing


   ALTER TABLE NashvilleHousing
   Add SaleDateConverted Date; 

   update NashvilleHousing
   SET SaleDateConverted = convert(Date, SaleDate)

-------------------------------------------------------------------------------
   ---Populate Property Address data

   select PropertyAddress
   from PortfolioProject.dbo.NashvilleHousing
   where PropertyAddress is null
   order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
   from PortfolioProject.dbo.NashvilleHousing a
   JOIN PortfolioProject.dbo.NashvilleHousing b
   on  a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
   where a.PropertyAddress is null

   UPDATE a
   SET  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
   from PortfolioProject.dbo.NashvilleHousing a
   JOIN PortfolioProject.dbo.NashvilleHousing b
   on  a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
   where a.PropertyAddress is null
-----------------------------------------------------------------------------------------

   --Breaking down the address into individual columns(ADDRESS, CITY , STATE)
   -- by using substring method

   select PropertyAddress
   from PortfolioProject.dbo.NashvilleHousing
   --where PropertyAddress is null
   --order by ParcelID

   select
   SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
   ,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address
   
   from PortfolioProject.dbo.NashvilleHousing

   ALTER TABLE NashvilleHousing
   Add PropertySplitAddress Nvarchar(255); 

   update NashvilleHousing
   SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

   ALTER TABLE NashvilleHousing
   Add PropertySplitCity Nvarchar(255); 

   update NashvilleHousing
   SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

  select *
  from PortfolioProject.dbo.NashvilleHousing
-----------------------------------------------------------------------------------

  --Now we will break the address into columns but with PARSE method
  

  select OwnerAddress
  from PortfolioProject.dbo.NashvilleHousing

  --Parse look for period '.' only. it returs individual segments from data
  --also it by default pick reverse length thats y state TN comes first, but we want vise versa so
  --we rearrange the numbers
  select
  PARSENAME(REPlACE(OwnerAddress,',','.') ,3),
 PARSENAME(REPlACE(OwnerAddress,',','.') ,2),
 PARSENAME(REPlACE(OwnerAddress,',','.') ,1)
  from PortfolioProject.dbo.NashvilleHousing

  -- now we add these colums to existing data


  ALTER TABLE NashvilleHousing
   Add ownerSplitAddress Nvarchar(255); 

   update NashvilleHousing
   SET ownerSplitAddress =  PARSENAME(REPlACE(OwnerAddress,',','.') ,3)

   ALTER TABLE NashvilleHousing
   Add ownerSplitCity Nvarchar(255); 

   update NashvilleHousing
   SET ownerSplitCity = PARSENAME(REPlACE(OwnerAddress,',','.') ,2)

   ALTER TABLE NashvilleHousing
   Add ownerSplitState Nvarchar(255); 

   update NashvilleHousing
   SET ownerSplitState = PARSENAME(REPlACE(OwnerAddress,',','.') ,1) 

   select *
  from PortfolioProject.dbo.NashvilleHousing
-----------------------------------------------------------------------------------

  --Change Y and N to yes and No in "sold as vacant" field

  select Distinct(SoldAsVacant)
  from PortfolioProject.dbo.NashvilleHousing

  select Distinct(SoldAsVacant), count(SoldAsVacant)
  from PortfolioProject.dbo.NashvilleHousing
  Group by SoldAsVacant
  order by 2



  select SoldAsVacant 
  , CASE When SoldAsVacant = 'Y' THEN 'YES'
        When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
   from PortfolioProject.dbo.NashvilleHousing

   UPDATE NashvilleHousing
   SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'YES'
        When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
   from PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------
---Remove Duplicates,,, we use CTE and some windows functions i.e Partition By

--these code i wrote to avoid hint table  error
ALTER DATABASE PortfolioProject
SET COMPATIBILITY_LEVEL = 90;

WITH RowNumCTE AS(
select *,
  Row_NUMBER() OVER (
  PARTITION BY ParcelId,
			  SalePrice,
			  LegalReference
			  ORDER BY
			  UniqueID
			  ) row_num
              

from PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
from RowNumCTE
WHERE row_num > 0
--order by ParcelID



--Delete Unused columns

select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

SELECT @@Version 














