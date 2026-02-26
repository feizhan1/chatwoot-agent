```
获取特定订单的详细信息，包括订单状态、产品列表、金额、付款信息等。

"status"字段指示订单状态：

- Pending payment（待付款）

- ReadyForShipment（正在准备发货）

- Shipped（订单已发货）

如果status为"Shipped"，建议调用"query-logistics-or-shipping-tracking-info-tool"工具获取跟踪信息。

使用场景：

- 用户询问：“我的订单状态是什么？”

- 用户询问：“我的订单何时发货？”

- 用户希望查看订单详情和处理状态

返回值（JSON）：
{
  "orderId": "string - 订单号",
  "discountedAmount": "number - 订单金额",
  "status": "string - 订单状态（Pending payment/ReadyForShipment/Shipped/Completed）",
  "createdOn": "string - 订单创建时间（ISO 8601）",
  "paymentOn": "string - 付款时间（ISO 8601）",
  "shippingDeliveryCycle": "string - 发货周期",
  "items": [
    {
      "sku": "string - SKU 代码",
      "productTitle": "string - 产品名称",
      "quantity": "number - 订单数量",
      "unitPrice": "number - 单价",
      "thumbnail": "string - 缩略图 URL（可选）",
      "url": "string - TVCMALL 产品页面 URL",
      "supplyChainInfo": {
        "stockQuantity"："number - 库存数量（准备中，可选）",
        "shippedQuantity"："number - 已发货数量,
        "shortageQuantity"："number - 缺货数量（可选）,
        "shortageNote"："string - 缺货备注（可选）",
        "estimatedArrivalTime"："string - 预计到达时间（可选）"
      }
    }
  ],
  "shippingPackages"：[
    {
      "orderId"："string - 订单号",
      "trackingNumber"："string - 追踪号码,
      "courierNumber"："string - 快递公司代码
    }
  ]
}
```