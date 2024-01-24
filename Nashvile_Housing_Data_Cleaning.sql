/*
"Nashville Housing Data Refinement: A SQL Cleansing Journey"
*/

-- Getting an overview of the Data

SELECT * 
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;

-------------------------------------------------------------------------

-- Standardize Date Format

-- Select original and standardized date format
SELECT 
    SaleDate AS OriginalSaleDate,
    CONVERT(DATE, SaleDate) AS SaleDateConverted
FROM 
    Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;

-- Update SaleDate column with standardized format
UPDATE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
SET SaleDate = CONVERT(DATE, SaleDate);

-------------------------------------------------------------------------

-- Populate Property Address data

-- Select all columns from the NashvilleHousing table
-- and order the results by ParcelID
SELECT *
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID;

-- Select data to update PropertyAddress where it is null
SELECT 
    a.ParcelID, 
    a.PropertyAddress AS OriginalPropertyAddress,
    b.ParcelID AS LinkedParcelID,
    b.PropertyAddress AS LinkedPropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS UpdatedPropertyAddress
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing a
JOIN Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Update PropertyAddress where it is null with a non-null linked PropertyAddress
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing a
JOIN Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Splitting PropertyAddress into individual columns
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS PropertySplitAddress,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertySplitCity
FROM
    Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;

-- Adding columns for split PropertyAddress
ALTER TABLE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
ADD PropertySplitCity NVARCHAR(255);

-- Updating new columns with split PropertyAddress values
UPDATE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Splitting OwnerAddress into individual columns
SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitState,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitAddress
FROM
    Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;

-- Adding columns for split OwnerAddress
ALTER TABLE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);

-- Updating new columns with split OwnerAddress values
UPDATE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

-- Display the updated table
SELECT *
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;

-------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Display distinct values and their counts in the "SoldAsVacant" field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- Display the "SoldAsVacant" field with 'Yes' and 'No' values
SELECT
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS UpdatedSoldAsVacant
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;

-- Update the "SoldAsVacant" field with 'Yes' and 'No' values
UPDATE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
SET SoldAsVacant = 
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
    -- ORDER BY ParcelID -- Uncomment if you want to specify an order
)
DELETE FROM RowNumCTE
WHERE row_num > 1;

-- After removing duplicates, you can select the remaining data
SELECT *
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;

-------------------------------------------------------------------------

-- Delete Unused Columns

-- Display data before deleting columns
SELECT *
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;

-- Delete unused columns
ALTER TABLE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

-- Display data after deleting columns
SELECT *
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;
