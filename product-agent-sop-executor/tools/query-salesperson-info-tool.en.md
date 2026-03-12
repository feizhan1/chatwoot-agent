Based on the user's email, query the corresponding salesperson's English name and salesperson's email.

This tool supports the following search methods:
- User's email `email`


Return value (JSON object):
{
  "Success": "boolean - Whether the query was successful",
  "ErrorMsg": "string | null - Error message, null when successful",
  "Data": {
    "BossUserId": "number - BOSS system user ID",
    "UserId": "string - User unique identifier (UUID)",
    "Email": "string - User email",
    "Phone": "string - User phone number; empty string indicates no phone number",
    "SalesMan": {
      "Id": "number - Salesperson ID",
      "CName": "string - Salesperson Chinese name",
      "EName": "string - Salesperson English name/system name",
      "Email": "string - Salesperson email"
    }
  }
}
