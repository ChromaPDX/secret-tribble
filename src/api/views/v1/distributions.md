## GET /v1/distributions.json

### Parameters
<table class="parameters">
<tr><td class="param">pool_id</td><td class="value">A valid pool ID</td></tr>
</table>

### Returns

If the `pool_id` is correct, a `distribution` will be returned:

	{
	    "pool_id" : ...,
	    "created_at" : timestamp,
		"splits" : {
			account_id : split_percent,
			...
		}
    }	

- `timestamp` will be an ISO 8601 date and time value, based in UTC +0.
- `split_percent` will be a string representation of a floating point value between 0.0 and 1.0. The sum of the `split_percent` values will *always* equal 1.0.

### Errors

Any errors are returned in a standard error object (TODO), with the following HTTP statuses.

<table class="errors">
<tr><td class="code">404</td><td class="reason">Distribution not found.</td></tr>
</table>

## POST /v1/distributions.json
