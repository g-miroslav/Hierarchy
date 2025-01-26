WITH BOM_CTE as (
SELECT
    BillOfMaterialsID
    , ProductAssemblyID
    , ComponentID
    , Product.Name as ComponentName
    , BOMLevel + 1 as BOMLevel
    , PerAssemblyQty
    , UnitMeasureCode
FROM
    Production.BillOfMaterials
    INNER JOIN Production.Product
        ON BillOfMaterials.ComponentID = Product.ProductID
WHERE
    EndDate IS NULL
)

, Recursive_CTE as (
SELECT
    *
    , CAST(NULL as varchar(50)) as AssemblyName
    , CAST(ComponentName as varchar(max)) as PathName
    , '"' + CAST(ComponentName as varchar(max)) + '"' as PathJson
    , 1 as Depth
FROM
    BOM_CTE
WHERE
    ProductAssemblyID IS NULL
UNION ALL
SELECT
    t.BillOfMaterialsID
    , t.ProductAssemblyID
    , t.ComponentID
    , t.ComponentName
    , t.BOMLevel
    , t.PerAssemblyQty
    , t.UnitMeasureCode
    , CAST(Recursive_CTE.ComponentName as varchar(50)) as AssemblyName
    , Recursive_CTE.PathName + '\' + CAST(t.ComponentName as varchar(max)) as PathName
    , Recursive_CTE.PathJson + ', "' + CAST(t.ComponentName as varchar(max)) + '"' as PathJson
    , Recursive_CTE.Depth + 1 as Depth
FROM
    BOM_CTE as t
    INNER JOIN Recursive_CTE
        ON t.ProductAssemblyID = Recursive_CTE.ComponentID
)

SELECT 
    BillOfMaterialsID
    , ProductAssemblyID
    , ComponentID
    , ComponentName
    , BOMLevel
    , PerAssemblyQty
    , UnitMeasureCode
    , JSON_VALUE('[' + PathJson + ']', '$[0]') as ComponentName1
    , JSON_VALUE('[' + PathJson + ']', '$[1]') as ComponentName2
    , JSON_VALUE('[' + PathJson + ']', '$[2]') as ComponentName3
    , JSON_VALUE('[' + PathJson + ']', '$[3]') as ComponentName4
    , JSON_VALUE('[' + PathJson + ']', '$[4]') as ComponentName5
    , AssemblyName
    , PathName
    , Depth
FROM
    Recursive_CTE;
