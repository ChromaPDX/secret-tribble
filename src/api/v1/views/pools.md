# /v1/pools.json

Pools represent how royalties are split and distributed amongst contributors.

## GET

| Param    | Description      |
| -----    | -----------      |
| token_id | A valid token_id |
| pool_id  | A valid pool_id  |

If the `pool_id` is correct, a `pool` will be returned:

### Response

```javascript
{
	"pool_id" : ...,
	"created_at" : timestamp,
	"splits" : {
		account_id : split_percent,
		...
	}
}
```

- `timestamp` will be an ISO 8601 date and time value, based in UTC +0.
- `split_percent` will be a string representation of a floating point value between 0.0 and 1.0. The sum of the `split_percent` values must *always* equal 1.0.

| Status | Description          |
| ------ | -----------          |
| 200    | Pool found.          |
| 401    | Invalid credentials. |
| 404    | Pool not found.      |

## POST

| Param    | Description                 |
| -----    | -----------                 |
| token_id | A valid token_id            |
| pool     | A valid, JSON encoded pool  |

See `GET` above for a description of the JSON structure for the `pool` parameter.

### Response

A successful response will contain a JSON pool representation for you to verify.

| Status | Description          |
| ------ | -----------          |
| 200    | Pool created.        |
| 401    | Invalid credentials. |


