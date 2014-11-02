## GET /v1/tokens.json

### Parameters
<table class="parameters">
<tr><td class="param">account_id</td><td>Your account ID</td></tr>
<tr><td class="param">secret_key</td><td>Your account's secret key</td></tr>
<tr><td class="param">token</td><td>a valid token</td></tr>
</table>

Passing `account_id` and `secret_key` will list all of the tokens for that account, along with any associated metadata.

Passing `token` will return whether or not the token is valid, along with any associated metadata.

## POST /v1/tokens.json

### Parameters
<table class="parameters">
<tr><td class="param">account_id</td><td>Your account ID</td></tr>
<tr><td class="param">secret_key</td><td>Your account's secret key</td></tr>
<tr><td class="optional param">metadata</td><td>A metadata string</td></tr>
</table>

This will create a new token, with an optional metadata string associated with it. The metadata can be used to differentiate how this particular token will be used.

## DELETE /v1/tokens.json

### Parameters
<table class="parameters">
<tr><td class="param">account_id</td><td>Your account ID</td></tr>
<tr><td class="param">secret_key</td><td>Your account's secret key</td></tr>
<tr><td class="param">token</td><td>The token to delete</td></tr>
</table>

This will immediately invalidate the specified token.
