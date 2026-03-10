```
基于用户的邮箱，查询对应业务员英文名、业务员邮箱。

此工具支持以下搜索方式：
- 用户的邮箱 `email`


返回值（JSON 对象）：
{
  "Success": "boolean - 是否查询成功",
  "ErrorMsg": "string | null - 错误信息，成功时为 null",
  "Data": {
    "BossUserId": "number - BOSS 系统用户 ID",
    "UserId": "string - 用户唯一标识（UUID）",
    "Email": "string - 用户邮箱",
    "Phone": "string - 用户手机号；为空字符串表示无手机号",
    "SalesMan": {
      "Id": "number - 业务员 ID",
      "CName": "string - 业务员中文名",
      "EName": "string - 业务员英文名/系统名",
      "Email": "string - 业务员邮箱"
    }
  }
}
```
