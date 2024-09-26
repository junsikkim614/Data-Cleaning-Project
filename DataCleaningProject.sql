SELECT * 
FROM nashvillehousing;

-- Populate Property Address Data 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID 
    AND a.`UniqueID` <> b.`UniqueID`
WHERE a.PropertyAddress IS NULL;

UPDATE NashvilleHousing a
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking Out Address into Individual Columns (Address, City, State) 
SELECT PropertyAddress
FROM NashvilleHousing;

SELECT 
SUBSTRING_INDEX(PropertyAddress, ',', 1) AS StreetAddress,
SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM NashvilleHousing;

ALTER TABLE nashvillehousing
ADD PropertySplitAddress NVARCHAR(255); 

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity NVARCHAR(255); 

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

SELECT 
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1) AS City,
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) AS State
FROM NashvilleHousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAdress NVARCHAR(255); 

UPDATE nashvillehousing
SET OwnerSplitAdress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity NVARCHAR(255); 

UPDATE nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1);

ALTER TABLE nashvillehousing
ADD OwnerSplitState NVARCHAR(255); 

UPDATE nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1);

-- Change Y and N to Yes and No in "Sold as Vacant" column 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant;

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
END;

-- Removing Duplicates 

WITH RowNumCTE AS (
    SELECT *, 
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM NashvilleHousing
)

DELETE n FROM NashvilleHousing n
INNER JOIN RowNumCTE r ON n.UniqueID = r.UniqueID
WHERE r.row_num > 1;

-- Deleting Unused Columns 
SELECT * 
FROM nashvillehousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;





