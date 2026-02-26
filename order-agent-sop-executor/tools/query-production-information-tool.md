```
根据自然语言关键词、SKU 代码或 SPU 代码从 TVCMall 搜索产品。

此工具支持使用以下方式搜索产品：
- 自然语言关键词（产品名称、类别、品牌、描述）
- 特定 SKU 代码（例如："6601167986A"）
- 特定 SPU 代码（例如："661100272"）

返回值（JSON 对象）：
{
  "products": [
    {
      "SKU": "string - 产品 SKU 代码",
      "Title": "string - 产品标题",
      "Image": "string - 缩略图 URL",
      "Url": "string - 产品详情页 URL",
      "Rate": "number - 产品评分（0-5）",
      "Reviews": "number - 评论数量",
      "Price": "number - 原价",
      "PriceFormat": "string - 格式化的原价",
      "DiscountedPrice": "number - 当前折扣价（忽略）",
      "DiscountedPriceFormat": "string - 格式化的折扣价（忽略）",
      "MinPrice": "number - 最低批发价",
      "MinPriceFormat": "string - 格式化的最低价格",
      "MinPriceQuantity": "number - 获得最低价的起订量",
      "MinQuantity": "number - 最小起订量（MOQ），产品的 MOQ 基于此字段",
      "Discount": "number - 折扣率",
      "CurrencySymbol": "string - 货币符号（例如：'$ - USD'）",
      "CatalogName": "string - 类别名称",
      "CatalogUrl": "string - 类别 URL",
      "LeadTime": "string - 备货时间（例如：'1 - 3 days'）",
      "StockStatus": "number - 库存状态代码",
      "SalesStatus": "number - 销售状态代码",
      "PublishDate": "string - 发布日期（ISO 8601 格式）",
      "IsCustomizable": "boolean - 产品是否可定制",
      "LogisticsTags": "string - 物流标签（例如：'Weak_Magnetism'）",
      "BoughtQuantity": "number - 用户已购买数量",
      "Properties": {
        "Brand": "string - 品牌名称",
        "Material": "string - 产品材质",
        "Color": "string - 产品颜色",
        "Gross Weight": "string - 产品毛重，保留三位小数，单位 kg",
        "Length": "number - 产品长度，保留两位小数",
        "Width": "number - 产品宽度，保留两位小数",
        "Height": "number - 产品高度，保留两位小数",
        "PackageLength": "number - 纸箱长度，保留两位小数",
        "PackageWidth": "number - 纸箱宽度，保留两位小数",
        "PackageHeight": "number - 纸箱高度，保留两位小数",
        "PackageQuantity": "string - 每箱数量",
        "Volume Weight": "number - 产品体积重，保留三位小数",
        "... more properties": "更多产品规格"
      },
      "SalesInfo": {
        "SalesPoint": "string - 产品卖点",
        "CostEffective": "boolean - 是否性价比高"
      },
      "Brand": {
        "code": "string - 品牌代码",
        "name": "string - 品牌名称",
        "image": "string - 品牌 Logo URL",
        "url": "string - 品牌页面 URL"
      },
      "PriceIntervals": [
        {
          "MinimumQuantity": "number - 此价格梯度的最小数量",
          "UnitPrice": "number - 该数量下的单价",
          "UnitPriceFormat": "string - 格式化的单价",
          "CurrentInterval": "boolean - 是否为当前价格梯度"
        }
      ],
      "Warehouse": ["number - 可用仓库 ID"],
      "ProductStatus": "number - 内部产品状态",
      "StockStatusDisplay": "number - 显示库存状态",
      "CornerMark": {
        "Type": "number - 角标类型",
        "Keyword": "string - 角标关键词"
      }
    }
  ],
  "page": "number - 当前页码（从 0 开始）",
  "pageSize": "number - 每页结果数",
  "total": "number - 结果总数",
  "query": "string - 使用的搜索查询",
  "tvcmallSearchUrl": "string - TVCMall 搜索结果页直链"
}

重要注意事项：
- 'PriceIntervals' 字段：过滤掉最小数量小于产品 MOQ 的价格梯度项。
- 'Properties' 字段：必须保留原始属性键名，不得修改。例如，'Gross Weight' 必须输出为 'Gross Weight'，不能简化为 'Weight'。
- 'tvcmallSearchUrl' 字段：提供 TVCMall 网站搜索结果的直链。始终在您的回复中包含此 URL，以便客户可以在 TVCMall 上浏览完整的搜索结果。
```
