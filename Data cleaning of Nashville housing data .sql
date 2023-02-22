select * from covid..NashVilleHousing

select saledate from covid..NashVilleHousing

-- change the saledate format with the convert function

select saledate, convert(date, saledate)
from covid..NashVilleHousing

update covid..NashVilleHousing
set saledate = CONVERT(date, saledate)

alter table covid..NashVilleHousing add saledateConv date

update covid..NashVilleHousing
set saledateConv = CONVERT(date, saledate)

select saledateConv from covid..NashVilleHousing

----------------------------------------------------------------
-- process the nulls in propertyAddress
select propertyAddress from covid..NashVilleHousing

select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress,
isnull(n1.PropertyAddress, n2.PropertyAddress)
from covid..NashVilleHousing n1
join covid..NashVilleHousing n2
on n1.ParcelID = n2.ParcelID
where n1.PropertyAddress is null and n2.PropertyAddress is not null
order by n1.ParcelID

update n1
set n1.PropertyAddress = isnull(n1.PropertyAddress, n2.PropertyAddress)
from covid..NashVilleHousing n1
join covid..NashVilleHousing n2
on n1.ParcelID = n2.ParcelID
where n1.PropertyAddress is null and n2.PropertyAddress is not null
---------------------------------------------------------------------------

select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as city
from covid..NashVilleHousing

alter table covid..NashVilleHousing add PropsplitAdd nvarchar(255)
alter table covid..NashVilleHousing add PropsplitCity nvarchar(255)

update covid..NashVilleHousing
set PropsplitAdd = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

update covid..NashVilleHousing
set PropsplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select propsplitAdd, PropsplitCity, PropertyAddress
from covid..NashVilleHousing

-- Another simpler way

select OwnerAddress, REPLACE(OwnerAddress, ',', '.')
from covid..NashVilleHousing

select OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAdd,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
from covid..NashVilleHousing

alter table covid..NashVilleHousing add OwnerSplitAdd nvarchar(255)
alter table covid..NashVilleHousing add OwnerSplitCity nvarchar(255)
alter table covid..NashVilleHousing add OwnerSplitState nvarchar(255)

update covid..NashVilleHousing
set OwnerSplitAdd = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

update covid..NashVilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

update covid..NashVilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select OwnerAddress, OwnerSplitAdd, PropsplitCity, OwnerSplitState
from covid..NashVilleHousing

------------------------------------------------------------------------
-- Process soldAsVacant column N No Y Yes
select distinct(soldAsVacant), count(soldAsVacant)
from covid..NashVilleHousing
group by soldAsVacant

update covid..NashVilleHousing
set SoldAsVacant = REPLACE(SoldAsVacant, 'Y', 'Yes')
where SoldAsVacant like 'Y'

update covid..NashVilleHousing
set SoldAsVacant = REPLACE(SoldAsVacant, 'N', 'No')
where SoldAsVacant like 'N'

-- OR
update NashVilleHousing
set SoldAsVacant = case  when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

--------------------------------------------------------------
--Remove duplicates
with rowNumCTE as 
(
select *,
ROW_NUMBER() Over(
Partition by ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference
Order by UniqueId
)row_number
from NashVilleHousing
)
select r1.ParcelId, r1.PropertyAddress, r1.SalePrice, r1.SaleDate, r1.LegalReference,
 r1.row_number
from rowNumCTE r1 join rowNumCTE r2
on r1.ParcelID = r2.ParcelID
where r2.row_number > 1
--delete from rowNumCTE where row_number > 1

-----------------------------------------------------------------------------
-- drop the unused column
alter table NashVilleHousing
drop column saleDate, propertyAddress, OwnerAddress


-------------------------------------------------------------------------------------