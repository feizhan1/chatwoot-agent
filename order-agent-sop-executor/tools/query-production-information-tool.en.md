Search for products from TVCMall based on natural language keywords, SKU codes, or SPU codes.

This tool supports searching for products using:
- Natural language keywords (product name, category, brand, description)
- Specific SKU code (e.g., "6601167986A")
- Specific SPU code (e.g., "661100272")

Return value (JSON object):
{
  "products": [
    {
      "SKU": "string - Product SKU code",
      "Title": "string - Product title",
      "Image": "string - Thumbnail URL",
      "Url": "string - Product detail page URL",
      "Rate": "number - Product rating (0-5)",
      "Reviews": "number - Number of reviews",
      "Price": "number - Original price",
      "PriceFormat": "string - Formatted original price",
      "DiscountedPrice": "number - Current discounted price (ignore)",
      "DiscountedPriceFormat": "string - Formatted discounted price (ignore)",
      "MinPrice": "number - Minimum wholesale price",
      "MinPriceFormat": "string - Formatted minimum price",
      "MinPriceQuantity": "number - Minimum order quantity to get the lowest price",
      "MinQuantity": "number - Minimum order quantity (MOQ), product MOQ is based on this field",
      "Discount": "number - Discount rate",
      "CurrencySymbol": "string - Currency symbol (e.g., '$ - USD')",
      "CatalogName": "string - Category name",
      "CatalogUrl": "string - Category URL",
      "LeadTime": "string - Lead time (e.g., '1 - 3 days')",
      "StockStatus": "number - Stock status code",
      "SalesStatus": "number - Sales status code",
      "PublishDate": "string - Publish date (ISO 8601 format)",
      "IsCustomizable": "boolean - Whether product is customizable",
      "LogisticsTags": "string - Logistics tags (e.g., 'Weak_Magnetism')",
      "BoughtQuantity": "number - Quantity already purchased by user",
      "Properties": {
        "Brand": "string - Brand name",
        "Material": "string - Product material",
        "Color": "string - Product color",
        "Gross Weight": "string - Product gross weight, three decimal places, unit kg",
        "Length": "number - Product length, two decimal places",
        "Width": "number - Product width, two decimal places",
        "Height": "number - Product height, two decimal places",
        "PackageLength": "number - Carton length, two decimal places",
        "PackageWidth": "number - Carton width, two decimal places",
        "PackageHeight": "number - Carton height, two decimal places",
        "PackageQuantity": "string - Quantity per carton",
        "Volume Weight": "number - Product volume weight, three decimal places",
        "... more properties": "More product specifications"
      },
      "SalesInfo": {
        "SalesPoint": "string - Product selling point",
        "CostEffective": "boolean - Whether cost-effective"
      },
      "Brand": {
        "code": "string - Brand code",
        "name": "string - Brand name",
        "image": "string - Brand logo URL",
        "url": "string - Brand page URL"
      },
      "PriceIntervals": [
        {
          "MinimumQuantity": "number - Minimum quantity for this price tier",
          "UnitPrice": "number - Unit price at this quantity",
          "UnitPriceFormat": "string - Formatted unit price",
          "CurrentInterval": "boolean - Whether this is the current price tier"
        }
      ],
      "Warehouse": ["number - Available warehouse IDs"],
      "ProductStatus": "number - Internal product status",
      "StockStatusDisplay": "number - Display stock status",
      "CornerMark": {
        "Type": "number - Corner mark type",
        "Keyword": "string - Corner mark keyword"
      }
    }
  ],
  "page": "number - Current page number (starting from 0)",
  "pageSize": "number - Number of results per page",
  "total": "number - Total number of results",
  "query": "string - Search query used",
  "tvcmallSearchUrl": "string - Direct link to TVCMall search results page"
}

Important notes:
- 'PriceIntervals' field: Filter out price tier items where minimum quantity is less than the product's MOQ.
- 'Properties' field: MUST preserve original property key names without modification. For example, 'Gross Weight' MUST be output as 'Gross Weight', not simplified to 'Weight'.
- 'tvcmallSearchUrl' field: Provides a direct link to the search results on TVCMall website. Always include this URL in your response so customers can browse the complete search results on TVCMall.
