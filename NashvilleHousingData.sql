
use Nashville_Housing;

select *
from NashvilleHousing;

--1) Standardise date format
select SaleDate,SaleDateConverted
from NashvilleHousing;

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate);

alter table	NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)


--2) Populate Property Address whereever it is null
select *
from NashvilleHousing

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;


--3) breaking property address into individual fields(Address,City,State)

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address
from NashvilleHousing

alter table	NashvilleHousing
add PropertyAddressModified nvarchar(255);

update NashvilleHousing
set PropertyAddressModified = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


alter table	NashvilleHousing
add CityAddress nvarchar(255);

update NashvilleHousing
set CityAddress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- breaking owner address

select PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from NashvilleHousing


alter table	NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table	NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table	NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


select *
from NashvilleHousing


--4) Change Y and N to Yes and NO in 'SoldAsvacant' Field

select distinct(SoldAsVacant),count(SoldAsVacant) 
from NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END


--5) Removing Duplicates from dataset
select * from NashvilleHousing;

with RowNumCte as(
select *,
ROW_NUMBER() over(
partition by ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference
			order by uniqueID
) as row_num
from NashvilleHousing
)
select *
from RowNumCte
where row_num>1