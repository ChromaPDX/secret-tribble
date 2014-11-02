# ChromaCoin API

It's bad ass!

## Caveats

This is obviously a work in progress!

## General Behavior

All of the resources return JSON data, and follow a generally RESTful access pattern. HTTP verbs and status codes are used extensively.

When errors occur, a standard error JSON object is returned, which may contain more than one error message:

    { "errors" : ["First", "Second", ...] }


To get documentation for any given resource, swap the `.json` suffix with `.html`. For example, to get documentation on the `/v1/distributions.json` resource, point your web browser at `/v1/distributions.html`.

## Headers

Every response returned by the API will contain the `Chroma-Processing-MS` header, which provides the number of milliseconds the server took to process the request. This can be used to aide debugging slow requests: "is it the server or network that's being slow?

## Running

*You must set up your vagrant environment as described in the `/README.md` file.*

Connect to your vagrant box, and go into the `/vagrant/src/api` directory.

- To run automated tests against your local API, use `rake test:api`
- To run a copy of the API, use `shotgun -o 0.0.0.0` to expose the app on port 9393. Shotgun is used because it automatically reloads the environment on every request.
- In production, `unicorn` will be used.

## Organization

Code for each resource or end point is contained in it's own file, found in the `v1/` directory.

Static documentation files are found in the `views/v1/` directory.

## Request / Response Environment

All requests have access to an `@errors` object (see `api_error.rb`). This will automatically be turned into JSON and returned instead of other data if any errors are present.

Similarly, all requests *must* assign their non-error output objects to the `@out` variable. This will automatically have `#to_json` called on it, so it must be serializable.
