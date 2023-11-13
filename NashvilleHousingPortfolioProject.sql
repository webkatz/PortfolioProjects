/*

cleaning data in SQL

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData



-- standardize date format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)



-- populate property address

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData
--WHERE PropertyAddress is null
Order By ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null



-- dividing address into multiple columns (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- change 1 to yes and 0 to no in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousingData
GROUP BY SoldAsVacant


SELECT SoldAsVacant 
, CASE WHEN SoldAsVacant = 1 THEN 'Yes'
       WHEN SoldAsVacant = 0 THEN 'No'
	   END 
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD SoldAsVacantConverted AS CASE WHEN SoldAsVacant = 1 THEN 'Yes'
       WHEN SoldAsVacant = 0 THEN 'No'
	   END



--remove duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDate, 
	LegalReference
	ORDER BY 
		UniqueID
		) row_num
FROM PortfolioProject.dbo.NashvilleHousingData
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1



-- delete unused columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
