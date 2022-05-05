/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleCleaningData

----------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleCleaningData

Update NashvilleCleaningData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleCleaningData
Add SaleDateConverted Date; 

Update NashvilleCleaningData
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleCleaningData
--Where PropertyAddress is null	
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
From PortfolioProject.dbo.NashvilleCleaningData a
JOIN PortfolioProject.dbo.NashvilleCleaningData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,  b.PropertyAddress)
From PortfolioProject.dbo.NashvilleCleaningData a
JOIN PortfolioProject.dbo.NashvilleCleaningData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-----------------------------------------------------------------------------------

-- Breaking out address into individual collumns (address, city, state)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleCleaningData
--Where PropertyAddress is null	
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))  as Address
From PortfolioProject.dbo.NashvilleCleaningData

ALTER TABLE NashvilleCleaningData
Add PropertySplitAddress nvarchar(255); 

Update NashvilleCleaningData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleCleaningData
Add PropertySplitCity nvarchar(255); 

Update NashvilleCleaningData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleCleaningData




Select OwnerAddress
From PortfolioProject.dbo.NashvilleCleaningData

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleCleaningData




ALTER TABLE NashvilleCleaningData
Add OwnerSplitAddress nvarchar(255); 

Update NashvilleCleaningData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleCleaningData
Add OwnerSplitCity nvarchar(255); 

Update NashvilleCleaningData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleCleaningData
Add OwnerSplitState nvarchar(255); 

Update NashvilleCleaningData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

----------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleCleaningData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleCleaningData

Update NashvilleCleaningData
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleCleaningData
--order by ParcelID
)
--DELETE
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleCleaningData

----------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleCleaningData

ALTER TABLE PortfolioProject.dbo.NashvilleCleaningData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleCleaningData
DROP COLUMN SaleDate