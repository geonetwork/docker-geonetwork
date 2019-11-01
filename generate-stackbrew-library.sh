#!/bin/bash
set -eu

declare -A aliases=(
        [3.0.5]='3.0'
        [3.2.2]='3.2'
        [3.4.4]='3.4'
        [3.6.0]='3.6'
        [3.8.2]='3.8 latest'

)

# builds to exclude from tagging
dirExclude=([3.0.5],[3.2.0],[3.2.1],[3.2.2],[3.4.0],[3.4.1],[3.4.2],[3.4.3],[3.4.4],[3.8.0],[3.8.1])

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

getArches() {
	local repo="$1"; shift
	local officialImagesUrl='https://github.com/docker-library/official-images/raw/master/library/'

	eval "declare -g -A parentRepoToArches=( $(
		find -name 'Dockerfile' -exec awk '
				toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
					print "'"$officialImagesUrl"'" $2
				}
			' '{}' + \
			| sort -u \
			| xargs bashbrew cat --format '[{{ .RepoName }}:{{ .TagName }}]="{{ join " " .TagEntry.Architectures }}"'
	) )"
}
getArches 'geonetwork'

cat <<-EOH
# this file is generated via https://github.com/geonetwork/docker-geonetwork/blob/$(fileCommit "$self")/$self

Maintainers: Joana Simoes <jo@doublebyte.net> (@doublebyte1),
	     Juan Luis Rodriguez <juanluisrp@geocat.net> (@juanluisrp)
GitRepo: https://github.com/geonetwork/docker-geonetwork
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for version in "${versions[@]}"; do
  if ! (echo ${dirExclude[@]} | grep -w $version > /dev/null) ; then

	commit="$(dirCommit "$version")"
	dir="$version"

	fullVersion="$(git show "$commit":"$version/Dockerfile" | awk '$1 == "ENV" && $2 == "GN_VERSION" { print $3; exit }')"

	versionAliases=(
		$version
		${aliases[$version]:-}
	)

	variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$dir/Dockerfile")"
	[ -n "$variantParent" ]
	variantArches="${parentRepoToArches[$variantParent]}"


	cat <<-EOE
		Tags: $(join ', ' "${versionAliases[@]}")
		GitCommit: $commit
		Directory: $version
	EOE

	for variant in postgres; do
		[ -f "$version/$variant/Dockerfile" ] || continue
		dir="$version/$variant"


		commit="$(dirCommit "$version/$variant")"

		variantAliases=( "${versionAliases[@]/%/-$variant}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$dir/Dockerfile")"
		[ -n "$variantParent" ]
		variantArches="${parentRepoToArches[$variantParent]}"

		echo
		cat <<-EOE
			Tags: $(join ', ' "${variantAliases[@]}")
			Architectures: $(join ', ' $variantArches)
			GitCommit: $commit
			Directory: $version/$variant
		EOE
	done
  fi
done
