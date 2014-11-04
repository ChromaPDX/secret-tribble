# /v1/tokens.json

Tokens are the basic authentication mechanism for the ChromaCoin API. Almost all requests will require a `token_id` to be passed as a parameter.

To issue, list, and delete tokens, you must use your `account_id` and `secret_key`.


## HEAD

| Param    | Description   |
| -------- | ------------- |
| token_id | A valid token |

Passing `token_id` will return whether or not the token is valid.

### Response

The body of the `HEAD` request will always be empty.

| Status | Description      |
| ------ | -----------      |
| 200    | Token found.     |
| 404    | Token not found. |


## GET

| Param      | Description               |
| ---        | -----------               |
| account_id | Your account ID           |
| secret_key | Your account's secret key |

Passing `account_id` and `secret_key` will list all of the tokens for that account, along with any associated metadata.

### Response

The response is a list of currently active tokens.

```javascript
[
	{ "token_id" : ..., "account_id" : ..., "metadata" : ..., "created_at" : ... },
	...
]
```

| Status | Description          |
| ------ | -----------          |
| 200    | Success.             |
| 401    | Invalid credentials. |


## POST

| Param      | Description               |
| ---        | -----------               |
| account_id | Your account ID           |
| secret_key | Your account's secret key |
| metadata   | A string                  |

This will create a new token, with an optional metadata string associated with it. The metadata can be used to differentiate how this particular token will be used.

### Response

Returns the new token.

```javascript
{ "token_id" : ..., "account_id" : ..., "metadata" : ..., "created_at" : ... }
```

| Status | Description         |
| ------ | -----------         |
| 200    | Success.            |
| 401    | Invalid credentials |


## DELETE

| Param      | Description               |
| ---        | -----------               |
| account_id | Your account ID           |
| secret_key | Your account's secret key |
| token_id   | The token to delete       |

This will immediately invalidate the specified token.

### Response

Returns the deleted token.

```javascript
{ "token_id" : ..., "account_id" : ..., "metadata" : ..., "created_at" : ... }
```

| Status | Description         |
| ------ | -----------         |
| 200    | Success             |
| 401    | Invalid credentials |
