#!/usr/bin/env bats

load "/usr/local/lib/bats/load.bash"

# Uncomment the following to get more detail on failures of stubs
# export CURL_STUB_DEBUG=/dev/tty
# export GIT_STUB_DEBUG=/dev/tty
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Fail without GITHUB_TOKEN" {

  stub buildkite-agent

  run "$PWD/hooks/command"

  assert_failure

  unstub buildkite-agent

}