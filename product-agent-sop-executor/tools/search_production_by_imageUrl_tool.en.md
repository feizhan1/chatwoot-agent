Search for similar products in TVCMall based on the image URL provided by the user (image-based search).

This tool uses image recognition technology to find visually similar products, suitable for scenarios where users cannot accurately describe the product name but can provide a product image.

Usage Scenarios:
- User provides image URL: "Search products by image URL(https://...)"
- User asks: "Find similar products with this image: https://..."
- User uploads image and asks: "Are there any products similar to this?"
- User provides competitor image: "Do you have products similar to this one? [image link]"

Input Requirements:
- **image_url** (required): Complete image URL address (must include http:// or https://)
- Supports common image formats: JPG, PNG, WEBP, etc.

Return Value (Array of Product Objects):
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
    "LeadTime": "string - Lead time (e.g., '1 - 3 days')",
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
      "Items": "array - Other SKUs under the same SPU (different colors/specifications)"
    }
  }
]

Notes:
- If the image URL is invalid or inaccessible, the tool will return an error
- If no similar products are found, returns empty array `[]`, should guide user to use keyword search or call need-human-help-tool
- Returned product array is sorted by similarity (higher similarity appears first)
- 'Image' and 'Url' fields are relative paths, need to concatenate with TVCMALL base domain (e.g., https://www.tvc-mall.com)
- 'Properties' field must display its original key names and cannot be modified, for example: 'Gross Weight' should not be output as 'Weight'
