# Nashville Housing Data Refinement: A SQL Cleansing Journey

### 1. Introduction

Welcome to the "Nashville Housing Data Refinement" project, a comprehensive exploration and refinement of the Nashville housing dataset using SQL. This documentation outlines the key steps taken to clean, standardize, and enhance the dataset, ensuring its readiness for analysis.

### 2. Overview of the Data

The project started with an overview of the original dataset, examining the structure and content of the 'NashvileHousing' table.

```sql
SELECT * 
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing;
```

### 3. Standardizing Date Format

To ensure consistency, the 'SaleDate' column was standardized by converting it to the appropriate date format.

```sql
UPDATE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
SET SaleDate = CONVERT(DATE, SaleDate);
```

### 4. Populating Property Address Data

Missing property addresses were populated by leveraging data from other records with the same 'ParcelID.'

```sql
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing a
JOIN Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
```

### 5. Breaking Out Address into Individual Columns

The 'PropertyAddress' and 'OwnerAddress' fields were split into separate columns for 'Address,' 'City,' and 'State' for improved analysis.

```sql
-- Splitting PropertyAddress into individual columns
-- Adding columns for split PropertyAddress
-- Updating new columns with split PropertyAddress values
```

### 6. Changing 'Y' and 'N' to 'Yes' and 'No'

The 'SoldAsVacant' field was updated to enhance interpretability, replacing 'Y' with 'Yes' and 'N' with 'No.'

```sql
UPDATE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
SET SoldAsVacant = 
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
```

### 7. Removing Duplicates

Duplicate entries were identified and removed based on key columns, ensuring data integrity.

```sql
WITH RowNumCTE AS (
    -- ...
)
DELETE FROM RowNumCTE
WHERE row_num > 1;
```

### 8. Deleting Unused Columns

Unused columns were deleted to streamline the dataset, focusing on essential information.

```sql
-- Delete unused columns
ALTER TABLE Nashvile_Housing_Data_Cleaning.dbo.NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
```

### 9. Key Highlights

- **Consistency**: Standardized date format and replaced ambiguous values with clear 'Yes' and 'No' indicators.
- **Completeness**: Populated missing property addresses and parsed detailed address components for better understanding.
- **Accuracy**: Removed duplicates based on key columns, ensuring data accuracy.
- **Efficiency**: Streamlined the dataset by removing unnecessary columns.

### 10. Conclusion

This project demonstrates the power of SQL in data cleaning and preparation, transforming raw data into a structured, accurate, and interpretable format. The refined dataset is now ready for advanced analysis, providing valuable insights into Nashville housing trends.

[Check the full SQL code here](https://github.com/GaurabKundu1/Nashville-Housing-Data-Refinement-A-SQL-Cleansing-Journey/blob/main/Nashvile_Housing_Data_Cleaning.sql)
