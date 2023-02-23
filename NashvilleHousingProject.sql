/*

Cleaning Data in SQL Queries

*/

--Remove unwanted columns

Alter table [dbo].[NashvilleHousing]
DROP Column [Unnamed: 0]


--Create new Cleaned table from source
SELECT 
[F1] as UniqueID,
[Parcel ID] as ParcelID,
[Land Use] as LandUse,
[Property Address] as PropertyAddress,
[Suite/ Condo   #] as SuiteCondo,
[Property City] as PropertyCity,
[Sale Date] as SaleDate,
[Sale Price] as SalePrice,
[Legal Reference] as LegalReference,
[Sold As Vacant] as SoldAsVacant,
[Multiple Parcels Involved in Sale] as MultipleParcels,
[Owner Name] as OwnerName,
[Address] as [Address],
[City] as City,
[State] as State,
[Acreage] as Average,
[Tax District] as TaxDistrict,
[Neighborhood] as Neighborhood,
[image] as [image],
[Land Value] as LandValue,
[Building Value] as BuildingValue,
[Total Value] as TotalValue,
[Finished Area] as FinishedArea,
[Foundation Type] as FoundationType,
[Year Built] as YearBuilt,
[Exterior Wall] as ExteriorWall,
[Grade] as Grade,
[Bedrooms] as Bedrooms,
[Full Bath] as FullBath,
[Half Bath] as HalfBath INTO NashvilleHousingCL 
FROM [dbo].[NashvilleHousing]


Select *
From PortfolioManagmentProject..NashvilleHousingCL

--Standardize Date Format

Select NashvilleHousingCL.[SaleDate], CONVERT(Date, NashvilleHousingCL.[SaleDate])
From PortfolioManagmentProject..NashvilleHousingCL

--Update NashvilleHousing
--SET [Sale Date] = CONVERT(Date, NashvilleHousing.[Sale Date])

ALter table NashvilleHousingCL
Add SaleDateConverted Date;

Update NashvilleHousingCL
SET SaleDateConverted = CONVERT(Date, NashvilleHousingCL.[SaleDate])

---------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioManagmentProject..NashvilleHousingCL
--Where [Property Address] is null
order by [ParcelID]


Select n.[ParcelID], n.[PropertyAddress], h.[ParcelID], h.[PropertyAddress], ISNULL(n.[PropertyAddress], h.[PropertyAddress])
From PortfolioManagmentProject..NashvilleHousingCL n
JOIN PortfolioManagmentProject..NashvilleHousingCL h
on n.[ParcelID] = h.[ParcelID] AND n.UniqueID <> h.UniqueID
Where n.[PropertyAddress] is null

Update n
SET [PropertyAddress] = ISNULL(n.[PropertyAddress], h.[PropertyAddress])
From PortfolioManagmentProject..NashvilleHousingCL n
JOIN PortfolioManagmentProject..NashvilleHousingCL h
on n.[ParcelID] = h.[ParcelID] AND n.UniqueID <> h.UniqueID
Where n.[PropertyAddress] is null

Delete FROM NashvilleHousingCL
Where PropertyAddress is null

--Concat Address, City, State into one column

Select PropertyAddress, Address, City, State, CONCAT(Address, ', ',City, ', ',State) as FullAddress
FROM dbo.NashvilleHousingCL
--Where Address is not null

Alter Table [dbo].[NashvilleHousingCL]
Add FullAddress nvarchar(255)

Update [dbo].[NashvilleHousingCL]
SET FullAddress = CONCAT(Address, ', ',City, ', ',State)


--Breaking out Address into Individual Columns (Address, City, State)

Select OwnerName
From PortfolioManagmentProject..NashvilleHousingCL

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)

FROM PortfolioManagmentProject..NashvilleHousingCL

--Remove Duplicates

With RowNumCTE AS(
Select *,
ROW_NUMBER () OVER (
Partition BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID
) row_num

FROM [dbo].[NashvilleHousingCL]
)
Select *  
From RowNumCTE
Where row_num > 1