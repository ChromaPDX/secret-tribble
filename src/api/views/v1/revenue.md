# /v1/revenue.json

## GET

| Param      | Description               |
| --------   | -------------             |
| token_id   | A valid token             |
| revenue_id | For an individual object  |
| pool_id    | For all revenue in a pool |

Returns a single revenue object, or all of the revenue for a given pool.

### Response

```json
{ "revenue_id" : ..., "pool_id" : ..., "amount" : ..., "currency" : ..., "created_at" : ... }
```

* `amount` is always represented as a string, to avoid floating point errors.
* `created_at` is ISO 8601 encoded for UTC +0
* `currency` will be three letter ISO 4217 currency code

Note that a `pool_id` query will return a list of revenue objects.

## POST

| Param    | Description   |
| -------- | ------------- |
| token_id | A valid token |
| pool_id  | The pool id   |
| amount   | The amount of revenue |
| currency | The currency code |

* Generally speaking, `amount` can range from 1B to 0.00001 units of a currency.
* Supported `currency` values are currently:
  * `BTC` - Bitcoin 

### Response

Returns a JSON representation of the revenue object, as outlined above.

