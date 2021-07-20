-- Cleaning Data in MySQL

SELECT *
From NashvilleHousing;

-- standardize date format

SELECT SaleDate, CAST(SaleDate AS Date)
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS Date);

-- populate property address data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- breaking out address to address, city, state

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , CHAR_LENGTH(PropertyAddress)) as City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , CHAR_LENGTH(PropertyAddress));

-- SELECT *
-- FROM NashvilleHousing;


SELECT OwnerAddress
FROM NashvilleHousing;

SELECT
SUBSTRING_INDEX(OwnerAddress, ',', 1) address, 
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) city, 
SUBSTRING_INDEX(OwnerAddress, ',', -1) state
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- SELECT *
-- FROM NashvilleHousing;

-- change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-- remove duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
)
DELETE a
FROM RowNumCTE
JOIN NashvilleHousing a USING(UniqueID)
WHERE row_num > 1;

-- delete unused columns

SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP OwnerAddress, 
DROP TaxDistrict, 
DROP PropertyAddress, 
DROP SaleDate;
