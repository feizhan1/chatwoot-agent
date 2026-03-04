Search for products from TVCMall based on customer's natural language query, SKU code, or SPU code.

This tool supports the following search methods:
- Natural language keywords (product name, category, brand, description)
- Specific SKU code (e.g., "6601167986A")
- Specific SPU code (e.g., "661100272")

Use cases:
- User asks: "Show me iPhone 17 cases"
- User asks: "Find Samsung phone chargers"
- User asks: "Do you have laptop screen protectors?"
- User provides SKU: "Query SKU 6601167986A"
- User provides SPU: "Show all products for SPU 661100272"

Return value (JSON object):
{
  "products": [
    {
      "SKU": "string - Product SKU code",
      "Title": "string - Product title",
      "Image": "string - Thumbnail URL",
      "Url": "string - Product detail page URL",
      "Price": "number - Unit price",
      "PriceFormat": "string - Formatted original price",
      "MinQuantity": "number - Minimum Order Quantity (MOQ), product MOQ is based on this value",
      "CatalogUrl": "string - Category URL",
      "LeadTime": "string - Lead time (e.g., '1 - 3 days')",
      "Properties": {
        "Brand": "string - Brand name",
        "Material": "string - Product material",
        "Color": "string - Product color",
        "Gross Weight": "string - Product gross weight, 3 decimal places, unit kg",
        "Length": "number - Product length, 2 decimal places",
        "Width": "number - Product width, 2 decimal places",
        "Height": "number - Product height, 2 decimal places",
        "PackageLength": "number - Carton length, 2 decimal places",
        "PackageWidth": "number - Carton width, 2 decimal places",
        "PackageHeight": "number - Carton height, 2 decimal places",
        "PackageQuantity": "string - Quantity per carton",
        "Volume Weight": "number - Product volume weight, 3 decimal places",
        "... more properties": "Other product specification parameters"
      },
      "PriceIntervals": [
        {
          "MinimumQuantity": "number - Minimum quantity for this tier",
          "UnitPrice": "number - Unit price at this quantity",
          "UnitPriceFormat": "string - Formatted unit price",
          "CurrentInterval": "boolean - Whether this is the current tier"
        }
      ]
    }
  ],
  "page": "number - Current page number (starting from 0)",
  "pageSize": "number - Number of results per page",
  "total": "number - Total number of results",
  "query": "string - Search query used",
  "tvcmallSearchUrl": "string - Direct link to TVCMall search results"
}

The 'Properties' field MUST display its original key names and cannot be modified, for example: 'Gross Weight' should not be output as 'Weight'.
The 'tvcmallSearchUrl' field represents the URL for searching on the TVCMALL website. When using this tool, this URL needs to be output to the customer and can be clicked to jump to the corresponding current search results on TVCMALL.
