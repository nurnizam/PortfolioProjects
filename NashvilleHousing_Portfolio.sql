SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

--Standardise Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;

SELECT SaleDate
FROM NashvilleHousing;


--Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
LEFT(PropertyAddress, CHARINDEX(',',(PropertyAddress))-1) as Address, 
	RIGHT(PropertyAddress,CHARINDEX(',', (REVERSE(PropertyAddress)))-1) as Address2
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',',(PropertyAddress))-1);

Update NashvilleHousing
Set PropertySplitCity = RIGHT(PropertyAddress,CHARINDEX(',', (REVERSE(PropertyAddress)))-1);

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as State
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);


--Change Yes and N to Yes and NO in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing;

Update NashvilleHousing
Set SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END;


--Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress;


