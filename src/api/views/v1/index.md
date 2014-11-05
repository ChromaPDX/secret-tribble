# Chroma Coin API v1 Documentation

### Authentication

Almost all requests require a `token_id` parameter. Tokens can be generated and managed via the [tokens](tokens.html) endpoint.

To get your first token, POST your username and password to the [accounts](accounts.html) endpoint.

### Errors

Errors are represented with HTTP status codes, and the body of the response will contain a JSON object containing the error messages:

```javascript
{ "errors" : ["Error Message 1", ...] }
```
