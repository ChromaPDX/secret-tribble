# /v1/accounts.json

## GET

| Param    | Description                 |
| -----    | -----------                 |
| token_id | A valid token_id            |

Returns an `account`:

```json
{ "account_id" : ..., "name" : ..., "created_at" : ... }
```

### Response

A successful response will contain a JSON pool representation for you to verify.

| Status | Description          |
| ------ | -----------          |
| 200    | Success.             |
| 401    | Invalid credentials. |


## POST

*Logs in to an account, given a user and password.*

| Param    | Description                 |
| -----    | -----------                 |
| user     | A valid username            |
| password | The account password        |

### Response

Returns a new `token` for the authenticated account.

| Status | Description          |
| ------ | -----------          |
| 200    | Success.             |
| 401    | Invalid credentials. |
