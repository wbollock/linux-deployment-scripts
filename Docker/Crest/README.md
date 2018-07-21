# Crest

Just some Docker things.

Currently works with `docker run $thing`, but needs to be made to work with `docker-compose` things too. 

### What can be specified for $image?

If you specify an image for `docker run` that is not currently on your system, it will be retrieved automatically using `docker pull`. Based on this behavior, `docker run` will accept images that follow the same naming convention as `docker pull`. See [docs.docker.com/engine/reference/commandline/pull/](https://docs.docker.com/engine/reference/commandline/pull/) for more detailed information.

### What parameters can I supply?

Currently, this calls `docker run $thing`, so you can specify any valid parameters to the `docker run` command. See [docs.docker.com/engine/reference/commandline/run/](https://docs.docker.com/engine/reference/commandline/run/) and [docs.docker.com/engine/reference/run/](https://docs.docker.com/engine/reference/run/) for more information and examples.
