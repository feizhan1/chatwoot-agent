Search for similar products in TVCMall based on image URL provided by user (image-based search).

This tool uses image recognition technology to find visually similar products, suitable for scenarios where users cannot accurately describe product names but can provide product images.

Usage Scenarios:
- User provides image URL: "Search products by image URL(https://...)"
- User inquires: "Find similar products with this image: https://..."
- User uploads image and asks: "Do you have similar products to this one?"
- User provides competitor image: "Do you have products similar to this? [image link]"

Input Requirements:
- **image_url** (required): Complete image URL address (must include http:// or https://)
- Supports common image formats: JPG, PNG, WEBP, etc.

Return Value (Product Object Array):
[
  {
    "SKU": "string - Product SKU code",
    "Title": "string - Product title",
    "Image": "string - Thumbnail relative path",
    "Url": "string - Product detail page relative path",
    "Price": "number - Unit price",
    "PriceFormat": "string - Formatted original price",
    "MinPrice": "number - Minimum price (bulk purchase)",
    "MinPriceFormat": "string - Formatted minimum price",
    "MinQuantity": "number - Minimum Order Quantity (MOQ)",
    "CatalogUrl": "string - Category URL",
    "LeadTime": "string - Delivery lead time (e.g., '1 - 3 days')",
    "StockStatus": "number - Stock status",
    "Properties": {
      "Brand": "string - Brand name",
      "Material": "string - Product material",
      "Color": "string - Product color",
      "Gross Weight": "string - Product gross weight, three decimal places, unit kg",
      "... more properties": "Other product specification parameters"
    },
    "PriceIntervals": [
      {
        "MinimumQuantity": "number - Minimum quantity for this tier",
        "UnitPrice": "number - Unit price at this quantity",
        "UnitPriceFormat": "string - Formatted unit price",
        "CurrentInterval": "boolean - Whether this is the current tier"
      }
    ],
    "Spu": {
      "GroupID": "number - SPU group ID",
      "Items": "array - Other SKUs under same SPU (different colors/specifications)"
    }
  }
]

Important Notes:
- If image URL is invalid or inaccessible, the tool will return an error
- If no similar products are found, returns empty array `[]`, should guide user to use keyword search or transfer to human agent
- Returned product array is sorted by similarity (higher ranking means more similar)
- 'Image' and 'Url' fields are relative paths, need to concatenate with TVCMALL base domain (e.g., https://www.tvc-mall.com)
- 'Properties' field MUST display its original key names and cannot be modified, for example: 'Gross Weight' should NOT be output as 'Weight'
