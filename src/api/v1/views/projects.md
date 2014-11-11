# /v1/projects.json

## GET

| Param      | Description               |
| --------   | -------------             |
| token_id   | A service token           |
| project_id | The ID for the project    |

### Response

```json
{ 'project_id' : ..., 'created_at' : ..., 'name' : ..., 'pool_id' : ... }
```

* Passing `splits` into the `include` parameter will add a `backers

## POST

| Param    | Description            |
| -------- | -------------          |
| token_id | A service token        |
| topic    | The name of the project. |
| body     | A JSON encoded object. |

### Response

Returns a JSON representation of the project object, as outlined above.

