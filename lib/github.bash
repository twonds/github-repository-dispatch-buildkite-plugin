#!/bin/bash

set -euo pipefail

api_calls_dir="${PWD}/tmp/github_api_calls"
export api_calls_dir


function repository_dispatch() {
    local repository=$1
    local event_type=$2
    local client_payload=$3

    payload=$(jq -n \
                 --compact-output \
                 --arg EVENT_TYPE "${event_type}" \
                 --argjson CLIENT_PAYLOAD "${client_payload}" \
                 '{ event_type: $EVENT_TYPE, client_payload: $CLIENT_PAYLOAD }')
    url="$(base_url "repos/${repository}")/dispatches"
    github_post request_dispatch "${url}" "${payload}"
}


function get_repository_dispatch() {
    local repository=$1
    local event_type=$2
    #local date_filter=$(date +"%Y-%m-%dT%H:%M")
    #local url=$(base_url "repos/${repository}/actions/runs?created=%3E${date_filter}")
    local url=""

    url=$(base_url "repos/${repository}/actions/runs?per_page=5")

    github_get get_actions_run "${url}"

}

function base_url() {
    local repo=$1
    local url=${GITHUB_API_URL:-https://api.github.com}

    echo "${url}/${repo}"
}

function github_get() {
    local name=$1
    local url=$2

    local response_file="${api_calls_dir}/${name}_response.json"
    local http_code
    http_code="$(curl --silent \
                    --write-out '%{http_code}'\
                    --header "Authorization: Bearer ${GITHUB_TOKEN}" \
                    --output "${response_file}" \
                    --request GET \
                    "${url}")"
  if [[ ! "${http_code}" =~ ^2[[:digit:]]{2}$ ]]; then
    echo "Github responded with ${http_code}:"
    cat "${response_file}"
    exit 1
  fi
}

function github_post() {
  local name=$1
  local url=$2
  local payload=$3
  local request_file="${api_calls_dir}/${name}_request.json"
  local response_file="${api_calls_dir}/${name}_response.json"
  local http_code

  mkdir -p "${api_calls_dir}" || true
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
