---Correct 'SaleDate' format to DATE

ALTER TABLE Public."Nashville_Housing"
ADD SaleDateConverted DATE;
UPDATE Public."Nashville_Housing"
SET SaleDateConverted = SaleDate::DATE;






--------------------------------------------------------------------------------------------------------






---Populate NULL Property Address Data

UPDATE Public."Nashville_Housing" AS t1
SET PropertyAddress = (
	SELECT PropertyAddress
  	FROM Public."Nashville_Housing" AS t2
  	WHERE t2.ParcelID = t1.ParcelID AND t2.PropertyAddress IS NOT NULL
  	LIMIT 1
)
WHERE PropertyAddress IS NULL;






--------------------------------------------------------------------------------------------------------





---Break Addres Into Individual Columns (Address, City, State)

SELECT SPLIT_PART(PropertyAddress, ',', 1) AS PropertyAddress, --Shows Address Separated From City
	SPLIT_PART(PropertyAddress, ',', 2) AS City
FROM Public."Nashville_Housing";



ALTER TABLE Public."Nashville_Housing"
ADD PropertySplitAddress varchar(100);
UPDATE Public."Nashville_Housing"
SET PropertySplitAddress = TRIM(SPLIT_PART(PropertyAddress, ',', 1));



ALTER TABLE Public."Nashville_Housing"
ADD PropertySplitCity varchar(100);
UPDATE Public."Nashville_Housing"
SET PropertySplitCity = TRIM(SPLIT_PART(PropertyAddress, ',', 2));



SELECT SPLIT_PART(OwnerAddress, ',', 1) AS OwnerPropertyAddress, ---Same As Before But With OwnerAddress
	SPLIT_PART(OwnerAddress, ',', 2) AS OwnerCity,
	SPLIT_PART(OwnerAddress, ',', 3) AS OwnerState
FROM Public."Nashville_Housing";



ALTER TABLE Public."Nashville_Housing"
ADD OwnerSplitAddress varchar(100),
ADD	OwnerSplitCity varchar(100),
ADD	OwnerSplitState varchar(100);
UPDATE Public."Nashville_Housing"
SET OwnerSplitAddress = TRIM(SPLIT_PART(OwnerAddress, ',', 1)),
	OwnerSplitCity = TRIM(SPLIT_PART(OwnerAddress, ',', 2)),
	OwnerSplitState = TRIM(SPLIT_PART(OwnerAddress, ',', 3));





--------------------------------------------------------------------------------------------------------




---Change 'Y' and 'N' to 'Yes' and 'No' in 'Sold As Vacant' Field

SELECT DISTINCT(SoldAsVacant)
FROM Public."Nashville_Housing";



UPDATE Public."Nashville_Housing"
SET SoldAsVacant = 
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
			 
			 



--------------------------------------------------------------------------------------------------------

					
					
					

---Delete Duplicates
					
WITH row_num_cte AS (SELECT ROW_NUMBER() OVER(PARTITION BY ParcelID, ---Creates a row number partition by almost all fields (only duplicates will have row_number > 1)
								   PropertyAddress,
					 			   SalePrice,
					 			   SaleDate,
					 			   LegalReference
					 ORDER BY UniqueID
						) AS row_num,
						UniqueID
FROM Public."Nashville_Housing")


DELETE
FROM Public."Nashville_Housing"
WHERE UniqueID IN (SELECT UniqueID
				  FROM row_num_cte
				  WHERE row_num <> 1)