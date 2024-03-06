curl https://login.salesforce.com/services/oauth2/token \
  -d "grant_type=password" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "username=YOUR_USERNAME" \
  -d "password=YOUR_PASSWORD" 


curl https://YOUR_INSTANCE.salesforce.com/services/data/vXX.0/sobjects/YourObject/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @your_data_file.json



  [
  {
    "Name": "Account 1",
    "Phone": "123-456-7890",
    "Website": "https://www.account1.com",
    "AnnualRevenue": 1000000,
    "Type": "Customer - Direct",
    "Industry": "Banking"
  },
  {
    "Name": "Account 2",
    "Phone": "098-765-4321",
    "Website": "https://www.account2.com",
    "AnnualRevenue": 2000000,
    "Type": "Customer - Channel",
    "Industry": "Retail"
  },
  {
    "Name": "Account 3",
    "Phone": "555-555-5555",
    "Website": "https://www.account3.com",
    "AnnualRevenue": 3000000,
    "Type": "Prospect",
    "Industry": "Technology"
  }
]


# 投入するJSONファイル
JSON_FILE="path/to/your_data_file.json"

# Salesforce REST APIエンドポイント
API_ENDPOINT="$INSTANCE_URL/services/data/vXX.0/sobjects/Account/"

# APIコールでデータを投入
curl -X POST $API_ENDPOINT \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @$JSON_FILE
