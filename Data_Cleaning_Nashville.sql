/* 
Cleaning Data In SQL Quries
*/

Use PortfolioProject

Select *
From PortfolioProject..NashvilleHousing
-------------------------------------------------------------------------------------

--Standardize Data Format

Select SaleDate, CONVERT(date,SaleDate)
From PortfolioProject..NashvilleHousing

--Update NashvilleHousing
--SET SaleDate = Convert(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = Convert(date,SaleDate)

Select SaleDate2 
From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------

--Populate Property Address Data

Select PropertyAddress 
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as PA
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

--Spliting PropertyAddress
Select
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address, 
Substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address2
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 


--SplittingOwnerAddress
Select OwnerAddress 
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
,CASE When SoldAsVacant = 'Y'  THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y'  THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

-------------------------------------------------------------------------------------

--Remove Duplicates

--Shows the duplicates
WITH RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by UniqueID
	) row_num
From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE 
Where row_num>1
Order by PropertyAddress

--DeleteDuplicates
WITH RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by UniqueID
	) row_num
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE 
Where row_num>1


Select *
From PortfolioProject..NashvilleHousing



-------------------------------------------------------------------------------------

--Delete Unused Columns

Alter Table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict








-------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
