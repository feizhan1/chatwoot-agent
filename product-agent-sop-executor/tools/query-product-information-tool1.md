```
基于客户的自然语言查询、SKU 代码或 SPU 代码从 TVCMall 搜索产品。

此工具支持以下搜索方式：
- 自然语言关键词（产品名称、类别、品牌、描述）
- 特定 SKU 代码（例如："6601167986A"）
- 特定 SPU 代码（例如："661100272"）

query 参数提取硬约束（必须遵守）：
- 当用户输入包含商品详情链接（如 https://www.tvcmall.com/details/bulk-purchasing-for-oppo-reno15-pro-max-5g-global-reno15-pro-5g-china-magnetic-case-soft-tpu-phone-back-cover-blue-sku6601207046a.html）时，优先从链接提取 query。
- 链接命中 `sku`+编号（如 `...-sku6601207046a.html`）时，query 只能输出编号本体（`6601207046a`），禁止输出整句、整条 URL 或 `sku` 前缀。
- 链接未命中 SKU 时，才使用 URL slug 中的产品名称或产品类型关键词。如当用户输入包含商品详情链接（https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html）时，从链接提取商品名称(Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black)作为query。
- query 只允许输出一个检索线索：SKU / 产品名称 / 产品类型关键词。

示例：
- 输入："I'd like to learn more about this product: https://www.tvcmall.com/details/...-sku6601207046a.html"
- query 正确输出："6601207046a"
- query 错误输出："I'd like to learn more about this product: https://..."

- 输入："I saw this product on Google. Do you have the same product? The product is https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html"
- query 正确输出："Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black"
- query 错误输出："https://www.sunsky-online.com/p/EDA003918912A/For-Google-Pixel-10-MagSafe-Magnetic-Frosted-Metal-Phone-Case-Black-.html"

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
