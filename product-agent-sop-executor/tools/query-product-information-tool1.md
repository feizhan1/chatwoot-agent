```
基于客户的自然语言查询、SKU 代码或 SPU 代码从 TVCMall 搜索产品。

此工具支持以下搜索方式：
- 自然语言关键词（产品名称、类别、品牌、描述）
- 特定 SKU 代码（例如："6601167986A"）
- 特定 SPU 代码（例如："661100272"）

使用场景：
- 用户询问："给我看看 iPhone 17 手机壳"
- 用户询问："找三星手机充电器"
- 用户询问："你们有笔记本电脑屏幕保护膜吗？"
- 用户提供 SKU："查询 SKU 6601167986A"
- 用户提供 SPU："显示 SPU 661100272 的所有产品"

返回值（JSON 对象）：
{
  "products": [
    {
      "SKU": "string - 产品 SKU 代码",
      "Title": "string - 产品标题",
      "Image": "string - 缩略图 URL",
      "Url": "string - 产品详情页 URL",
      "Price": "number - 单价",
      "PriceFormat": "string - 格式化的原始价格",
      "MinQuantity": "number - 最小起订量（MOQ），产品的 MOQ 基于此值",
      "CatalogUrl": "string - 分类 URL",
      "LeadTime": "string - 交货周期（例如：'1 - 3 days'）",
      "Properties": {
        "Brand": "string - 品牌名称",
        "Material": "string - 产品材质",
        "Color": "string - 产品颜色",
        "Gross Weight": "string - 产品毛重，保留三位小数，单位 kg",
        "Length": "number - 产品长度，保留两位小数",
        "Width": "number - 产品宽度，保留两位小数",
        "Height": "number - 产品高度，保留两位小数",
        "PackageLength": "number - 外箱长度，保留两位小数",
        "PackageWidth": "number - 外箱宽度，保留两位小数",
        "PackageHeight": "number - 外箱高度，保留两位小数",
        "PackageQuantity": "string - 每箱数量",
        "Volume Weight": "number - 产品体积重，保留三位小数",
        "... more properties": "其他产品规格参数"
      },
      "PriceIntervals": [
        {
          "MinimumQuantity": "number - 此阶梯的最小数量",
          "UnitPrice": "number - 此数量下的单价",
          "UnitPriceFormat": "string - 格式化的单价",
          "CurrentInterval": "boolean - 是否为当前阶梯"
        }
      ]
    }
  ],
  "page": "number - 当前页码（从 0 开始）",
  "pageSize": "number - 每页结果数",
  "total": "number - 结果总数",
  "query": "string - 使用的搜索查询",
  "tvcmallSearchUrl": "string - TVCMall 搜索结果的直接链接"
}

'Properties' 字段必须显示其原始键名，不能被修改，例如：'Gross Weight' 不应输出为 'Weight'。
'tvcmallSearchUrl' 字段表示在 TVCMALL 网站上搜索的 URL。使用此工具时，需要将此 URL 输出给客户，并可点击跳转到 TVCMALL 上对应的当前搜索结果。



```