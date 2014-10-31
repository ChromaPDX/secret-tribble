# ChromaCoin API

It's bad ass!

## General Behavior

All of the resources return JSON data, and follow a generally RESTful access pattern. HTTP verbs and status codes are used extensively.

When errors occur, a standard error JSON object is returned, which may contain more than one error message:

    { "errors" : ["First", "Second", ...] }

To get documentation for any given resource, swap the `.json` suffix with `.html`. For example, to get documentation on the `/v1/distributions.json` resource, point your web browser at `/v1/distributions.html`.

## Running

*You must set up your vagrant environment as described in the `/README.md` file.*

Connect to your vagrant box, and go into the `/vagrant/src/api` directory.

- For a development environment, use `shotgun -o 0.0.0.0` to expose the app on port 9393. Shotgun is used because it automatically reloads the environment on every request.
- In production, `unicorn` will be used.



