# /v1/queues.json

**The `queues` resource is an internal API. Standard issued tokens will NOT work.**

## GET

| Param      | Description               |
| --------   | -------------             |
| token_id   | A service token           |
| topic      | The name of the queue.    |

Returns the oldest message for the given topic, or an empty JSON object if there is none.

### Response

```json
{ "topic" : ..., "created_at" : timestamp, "message_id" : ..., "body" : { ... } }
```

## POST

| Param    | Description            |
| -------- | -------------          |
| token_id | A service token        |
| topic    | The name of the queue. |
| body     | A JSON encoded object. |

### Response

Returns a JSON representation of the queue object, as outlined above.

