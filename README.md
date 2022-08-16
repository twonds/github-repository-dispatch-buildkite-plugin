# github-repository-dispatch-buildkite-plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) that lets you trigger a Github workflow via a repository dispatch.

## Example



```yml
steps:
  - label: ":github: Trigger github workflow"
    plugins:
      - twonds/github-repository-dispatch#v0.1.0:
          repository: <your_path_to_repo>
          event_type: <the_event_type_for_workflow>
```

## Configuration

### `repository` (Required, string)

The repository path to use

### `event_type` (Required, string)

The event type of the workflow to indicate what workflow event to trigger.

## Developing

To run the tests:

```shell
docker-compose run --rm tests
```

## Contributing

1. Fork the repo
2. Make the changes
3. Run the tests
4. Commit and push your changes
5. Send a pull request

## TODO

[ ] Trigger Github workflow
[ ] Wait for workflow to complete
[ ] Wait on certain workflow status
[ ] Report on Github workflow URL and status
