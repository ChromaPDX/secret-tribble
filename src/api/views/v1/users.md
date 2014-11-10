# /v1/users.json

## GET

| Param    | Description                 |
| -----    | -----------                 |
| token_id | A valid token_id            |

Returns an `user`:

```json
{ "user_id" : ..., "name" : ..., "created_at" : ... }
```

### Response

A successful response will contain a JSON pool representation for you to verify.

| Status | Description          |
| ------ | -----------          |
| 200    | Success.             |
| 401    | Invalid credentials. |


## POST

*Logs in to an user, given a user and password.*

| Param    | Description                 |
| -----    | -----------                 |
| user     | A valid username            |
| password | The user password        |

### Response

Returns a new `token` for the authenticated user.

| Status | Description          |
| ------ | -----------          |
| 200    | Success.             |
| 401    | Invalid credentials. |
