Search for products from TVCMall based on customer's natural language query, SKU code, or SPU code.

This tool supports the following search methods:
- Natural language keywords (product name, category, brand, description)
- Specific SKU code (e.g., "6601167986A")
- Specific SPU code (e.g., "661100272")

query parameter extraction hard constraints (MUST follow):
- When user input contains a product detail link (e.g., https://www.tvcmall.com/details/bulk-purchasing-for-oppo-reno15-pro-max-5g-global-reno15-pro-5g-china-magnetic-case-soft-tpu-phone-back-cover-blue-sku6601207046a.html), prioritize extracting query from the link.
- When link matches `sku`+code (e.g., `...-sku6601207046a.html`), query can only output the code itself (`6601207046a`), DO NOT output full sentence, entire URL, or `sku` prefix.
- When link does not match SKU, only then use product name or product type keywords from URL slug. For example, when user input contains a product detail link (https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html), extract product name (Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black) from link as query.
- query can only output one search clue: SKU / product name / product type keyword.

Examples:
- Input: "I'd like to learn more about this product: https://www.tvcmall.com/details/...-sku6601207046a.html"
- query correct output: "6601207046a"
- query incorrect output: "I'd like to learn more about this product: https://..."

- Input: "I saw this product on Google. Do you have the same product? The product is https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html"
- query correct output: "Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black"
- query incorrect output: "https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html"

Use cases:
- User asks: "Show me iPhone 17 phone cases"
- User asks: "Find Samsung phone chargers"
- User asks: "Do you have laptop screen protectors?"
- User provides SKU: "Query SKU 6601167986A"
- User provides SPU: "Display all products for SPU 661100272"

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
      "MinQuantity": "number - Minimum order quantity (MOQ), product's MOQ is based on this value",
      "CatalogUrl": "string - Category URL",
      "LeadTime": "string - Lead time (e.g., '1 - 3 days')",
      "Properties": {
        "Brand": "string - Brand name",
        "Material": "string - Product material",
        "Color": "string - Product color",
        "Gross Weight": "string - Product gross weight, keep three decimal places, unit kg",
        "Length": "number - Product length, keep two decimal places",
        "Width": "number - Product width, keep two decimal places",
        "Height": "number - Product height, keep two decimal places",
        "PackageLength": "number - Carton length, keep two decimal places",
        "PackageWidth": "number - Carton width, keep two decimal places",
        "PackageHeight": "number - Carton height, keep two decimal places",
        "PackageQuantity": "string - Quantity per carton",
        "Volume Weight": "number - Product volume weight, keep three decimal places",
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
