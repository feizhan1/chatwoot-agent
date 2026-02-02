```
基于用户提供的图片 URL 搜索 TVCMall 中的相似产品（以图搜图）。

此工具通过图像识别技术，找到视觉上相似的产品，适用于用户无法准确描述产品名称，但可以提供产品图片的场景。

使用场景：
- 用户提供图片 URL："Search products by image URL(https://...)"
- 用户询问："Find similar products with this image: https://..."
- 用户上传图片后询问："有类似这个的产品吗？"
- 用户提供竞品图片："你们有没有类似这款的产品？[图片链接]"

输入要求：
- **image_url**（必填）：完整的图片 URL 地址（需包含 http:// 或 https://）
- 支持常见图片格式：JPG、PNG、WEBP 等

返回值（产品对象数组）：
[
  {
    "SKU": "string - 产品 SKU 代码",
    "Title": "string - 产品标题",
    "Image": "string - 缩略图相对路径",
    "Url": "string - 产品详情页相对路径",
    "Price": "number - 单价",
    "PriceFormat": "string - 格式化的原始价格",
    "MinPrice": "number - 最低价格（批量采购）",
    "MinPriceFormat": "string - 格式化的最低价格",
    "MinQuantity": "number - 最小起订量（MOQ）",
    "CatalogUrl": "string - 分类 URL",
    "LeadTime": "string - 交货周期（例如：'1 - 3 days'）",
    "StockStatus": "number - 库存状态",
    "Properties": {
      "Brand": "string - 品牌名称",
      "Material": "string - 产品材质",
      "Color": "string - 产品颜色",
      "Gross Weight": "string - 产品毛重，保留三位小数，单位 kg",
      "... more properties": "其他产品规格参数"
    },
    "PriceIntervals": [
      {
        "MinimumQuantity": "number - 此阶梯的最小数量",
        "UnitPrice": "number - 此数量下的单价",
        "UnitPriceFormat": "string - 格式化的单价",
        "CurrentInterval": "boolean - 是否为当前阶梯"
      }
    ],
    "Spu": {
      "GroupID": "number - SPU 组 ID",
      "Items": "array - 同 SPU 下的其他 SKU（不同颜色/规格）"
    }
  }
]

注意事项：
- 如果图片 URL 无效或无法访问，工具将返回错误
- 如果未找到相似产品，返回空数组 `[]`，应引导用户使用关键词搜索或转人工
- 返回的产品数组按相似度排序（越靠前越相似）
- 'Image' 和 'Url' 字段为相对路径，需拼接 TVCMALL 基础域名（如 https://www.tvc-mall.com）
- 'Properties' 字段必须显示其原始键名，不能被修改，例如：'Gross Weight' 不应输出为 'Weight'
```
