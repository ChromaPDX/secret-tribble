# /v1/projects.json

**The `projects` resource is an internal API. Standard issued tokens will NOT work.**

## GET

| Param      | Description               |
| --------   | -------------             |
| token_id   | A service token           |
| topic      | The name of the project.    |

Returns the oldest message for the given topic, or an empty JSON object if there is none.

### Response

```json
{ "topic" : ..., "created_at" : timestamp, "message_id" : ..., "body" : { ... } }
```

## POST

| Param    | Description            |
| -------- | -------------          |
| token_id | A service token        |
| topic    | The name of the project. |
| body     | A JSON encoded object. |

### Response

Returns a JSON representation of the project object, as outlined above.

