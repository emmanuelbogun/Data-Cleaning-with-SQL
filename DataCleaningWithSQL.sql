
/*
DATA CLEANING WITH SQL QUERIES 
*/

Select * 
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------

---- Formatting the Date Column ----
Select SaleDate
From PortfolioProject..NashvilleHousing

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Alternatively ---
Alter Table PortfolioProject..NashvilleHousing
Add SaleDateCoverted Date

Update PortfolioProject..NashvilleHousing
Set SaleDateCoverted = CONVERT(Date, SaleDate)

Select * from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------

-- Populate the PropertyAddress

Select PropertyAddress From PortfolioProject..NashvilleHousing
 Where PropertyAddress is null

 Select ParcelID, PropertyAddress 
 From PortfolioProject..NashvilleHousing
 Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-- To check if any Address is still null
Select PropertyAddress
From PortfolioProject..NashvilleHousing
where PropertyAddress is null

------------------------------------------------------------------------------------------------

-- Breaking Out PropertyAddress Data into Address, City & State.

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

-- Inputting the newly formed columns into the table
-- Column 1
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

-- Column 2
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select * 
From PortfolioProject..NashvilleHousing


-- Breaking Out OwnerAddress Data into Address, City & State.
/* 
This time around we'll be using a different function called -- PARSENAME()
*/

Select OwnerAddress 
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnersplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
From PortfolioProject..NashvilleHousing

-- Adding the newly formed columns into the table

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
from PortfolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------


--- CHANGE Y AND N TO YES AND NO RESPECTIVELY IN THE SoldAsVacant Column

Select Distinct(SoldAsVacant)
from PortfolioProject..NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

Select * 
From PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------

-- Remove duplicates

Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num
From PortfolioProject..NashvilleHousing

--Using CTE

WITH RowNumCTE AS(
Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num
From PortfolioProject..NashvilleHousing)

Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Deleting them
WITH RowNumCTE AS(
Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num
From PortfolioProject..NashvilleHousing)

DELETE 
From RowNumCTE
Where row_num > 1
-- Order by PropertyAddress
------------ you can check again to verify change the DELETE to SELECT *


------ DELETE UNUSED COLUMNS --
Select * 
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict