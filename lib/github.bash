#!/bin/bash

set -euo pipefail

function repository_dispatch() {
    local repository=$1
    local event_type=$2
    local client_payload=$3

    payload=$(jq -n \
                 --compact-output \
                 --arg EVENT_TYPE "${event_type}" \
                 --arg CLIENT_PAYLOAD "${client_payload}" \
                 '{ event_type: $EVENT_TYPE, client_payload: $CLIENT_PAYLOAD }')
    url="$(base_url "repos/${repo}")/dispatches"
    github_post request_dispatch "${url}" "${payload}"
}

function base_url() {
    local repo=$1
    local url=${GITHUB_API_URL:-https://api.github.com}

    echo "${url}/${repo}"
}

function github_post() {
  local name=$1
  local url=$2
  local payload=$3
  local temp_dir='tmp/github_api_calls'
  local request_file="${temp_dir}/${name}_request.json"
  local response_file="${temp_dir}/${name}_response.json"
  local http_code

  mkdir -p "${temp_dir}"
  echo "${payload}" > "${request_file}"

  http_code="$(curl --silent \
                    --write-out '%{http_code}'\
                    --data "${payload}" \
                    --header "Authorization: Bearer ${GITHUB_TOKEN}" \
                    --output "${response_file}" \
                    --request POST \
                    "${url}")"
  if [[ ! "${http_code}" =~ ^2[[:digit:]]{2}$ ]]; then
    echo "Github responded with ${http_code}:"
    cat "${response_file}"
    exit 1
  fi
}
