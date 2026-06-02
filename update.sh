#!/bin/bash
set -eo pipefail

cd "$(dirname "$BASH_SOURCE")"

if sed --version 2>/dev/null | grep -q GNU; then
	sedi() { sed -Ei "$@"; }
else
	sedi() { sed -Ei '' "$@"; }
fi

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( [0-9]*/ )
fi
versions=( "${versions[@]%/}" )


for version in "${versions[@]}"; do
	echo "Updating Dockerfile for ${version} version"
	sha256="$(curl -fsSL --retry 5 "https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${version}/geonetwork.war.sha256/download" | awk '{print $1;}')"
	if [[ -z "$sha256" ]]; then
		sha256="$(curl -fsSL --retry 5 "https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${version}/geonetwork.war.SHA256/download" | awk '{print $1;}')"
	fi
	if [[ -z "$sha256" ]]; then
		echo "ERROR: could not fetch SHA256 for GeoNetwork ${version}" >&2
		exit 1
	fi
	echo "SHA256 for GeoNetwork ${version} is ${sha256}"

	echo "Updating ${version}/Dockerfile"
	sedi \
		-e 's/^(ENV GN_VERSION) .*/\1 '"$version"'/' \
		-e 's/^(ENV GN_DOWNLOAD_SHA256) .*/\1 '"$sha256"'/' \
		"$version/Dockerfile"

	if [[ -f "$version/postgres/Dockerfile" ]]; then
		echo "Updating ${version}/postgres/Dockerfile"
		sedi \
			-e 's/^(FROM geonetwork):.*/\1:'"$version"'/' \
			"$version/postgres/Dockerfile"
	fi

	if [[ -f "$version/docker-compose.yml" ]]; then
		echo "Updating microservices reference"
		sedi \
			-e "s#geonetwork/gn-cloud-ogc-api-records-service:.*#geonetwork/gn-cloud-ogc-api-records-service:${version}-0#" \
			"$version/docker-compose.yml"
	fi

	if [[ -f "$version/README.md" ]]; then
		echo "Updating ${version}/README.md"
		sedi \
			-e 's/(# Version )[0-9]+\.[0-9]+\.[0-9]+/\1'"$version"'/g' \
			-e 's/(docker-geonetwork\/)[0-9]+\.[0-9]+\.[0-9]+/\1'"$version"'/g' \
			-e 's/(geonetwork:)[0-9]+\.[0-9]+\.[0-9]+/\1'"$version"'/g' \
			-e 's/(GeoNetwork )[0-9]+\.[0-9]+\.[0-9]+/\1'"$version"'/g' \
			"$version/README.md"
	fi
done
