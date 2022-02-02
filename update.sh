#!/bin/bash
set -eo pipefail

cd "$(dirname "$BASH_SOURCE")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	echo "Updating Dockerfile for ${version} version"
	md5="$(curl -fsSL --retry 5 "https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${version}/geonetwork.war.md5/download" | awk '{print $1;}')"
	echo "MD5 for GeoNetwork ${version} is ${md5}"

	sed -ri \
		-e 's/^(ENV GN_VERSION) .*/\1 '"$version"'/' \
		-e 's/^(ENV GN_DOWNLOAD_MD5) .*/\1 '"$md5"'/' \
		-e 's/^(FROM geonetwork):.*/\1:'"$version"'/' \
		"$version/Dockerfile" "$version/postgres/Dockerfile"
done
