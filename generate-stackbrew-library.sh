#!/bin/bash
set -eu

# Bash 4+ required for associative arrays
if ((BASH_VERSINFO[0] < 4)); then
    echo "Bash 4 or above is required."
    exit 1
fi

declare -A aliases=(
    [3.0.5]='3.0'
    [3.2.2]='3.2'
    [3.4.4]='3.4'
    [3.6.0]='3.6'
    [3.8.3]='3.8'
    [3.10.10]='3.10'
    [3.12.12]='3.12 3'
    [4.2.15]='4.2'
    [4.4.11]='4.4 4 latest'
)

declare -A dirExclude=(
    [3.0.5]=1 
	[3.2.0]=1 [3.2.1]=1 [3.2.2]=1 [3.4.0]=1 [3.4.1]=1 [3.4.2]=1 [3.4.3]=1 [3.4.4]=1
    [3.6.0]=1 [3.8.0]=1 [3.8.1]=1 [3.8.2]=1 [3.8.3]=1 
	[3.10.0]=1 [3.10.1]=1 [3.10.2]=1 [3.10.3]=1 [3.10.4]=1 [3.10.5]=1 [3.10.6]=1 [3.10.7]=1 [3.10.8]=1 [3.10.9]=1 [3.10.10]=1 [3.12.0]=1 [3.12.1]=1
    [3.12.2]=1 [3.12.3]=1 [3.12.4]=1 [3.12.5]=1 [3.12.6]=1 [3.12.7]=1 [3.12.8]=1 [3.12.9]=1 [3.12.10]=1 [3.12.11]=1 
	[4.0.0-alpha.1]=1 [4.0.0-alpha.2]=1 [4.0.0]=1 [4.0.1]=1 [4.0.2]=1 [4.0.3]=1 [4.0.4]=1 [4.0.5]=1 [4.0.6]=1 
	[4.2.0]=1 [4.2.1]=1 [4.2.2]=1 [4.2.3]=1 [4.2.4]=1 [4.2.5]=1 [4.2.6]=1 [4.2.7]=1 [4.2.8]=1 [4.2.9]=1 [4.2.10]=1 [4.2.11]=1 [4.2.12]=1 [4.2.13]=1 [4.2.14]=1
	[4.4.0]=1 [4.4.1]=1 [4.4.2]=1 [4.4.3]=1 [4.4.4]=1 [4.4.5]=1 [4.4.6]=1 [4.4.7]=1 [4.4.8]=1 [4.4.9]=1 [4.4.10]=1
)

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )

fileCommit() {
    git log -1 --format='format:%H' HEAD -- "$@"
}

dirCommit() {
    local dir="$1"; shift
    (
        cd "$dir"
        fileCommit \
            Dockerfile \
            $(git show HEAD:./Dockerfile | awk '
                toupper($1) == "COPY" {
                    for (i = 2; i < NF; i++) { print $i }
                }
            ')
    )
}

join() {
    local sep="$1"; shift
    local out; printf -v out "${sep//%/%%}%s" "$@"
    echo "${out#$sep}"
}

getArches() {
    local repo="$1"
    local officialImagesUrl='https://github.com/docker-library/official-images/raw/master/library/'
    
    # Build the eval string with proper escaping for associative array check
    local evalString=""
    for version in "${versions[@]}"; do
        if [[ -z ${dirExclude[$version]+x} ]]; then
            evalString+="$(
                find "$version" -name 'Dockerfile' -exec awk '
                    toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
                        print "'"$officialImagesUrl"'" $2
                    }
                ' '{}' + |
                sort -u |
                xargs -r bashbrew cat --format '[{{ .RepoName }}:{{ .TagName }}]="{{ join " " .TagEntry.Architectures }}"'
            ) "
        fi
    done
    
    eval "declare -g -A parentRepoToArches=( $evalString )"
}
getArches 'geonetwork'

cat <<-EOH
# this file is generated via https://github.com/geonetwork/docker-geonetwork/blob/$(fileCommit "$self")/$self

Maintainers: Joana Simoes <jo@doublebyte.net> (@doublebyte1),
         Juan Luis Rodriguez <juanluisrp@geocat.net> (@juanluisrp),
         Jose Garcia <jose.garcia@geocat.net> (@josegar74)
GitRepo: https://github.com/geonetwork/docker-geonetwork.git
GitFetch: refs/heads/main
EOH

for version in "${versions[@]}"; do
    if [[ -z ${dirExclude[$version]+x} ]]; then
        commit="$(dirCommit "$version")"
        dir="$version"
        fullVersion="$(git show "$commit":"$version/Dockerfile" | awk '$1 == "ENV" && $2 == "GN_VERSION" { print $3; exit }')"
        versionAliases=( "$version" ${aliases[$version]:-} )
        variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$dir/Dockerfile")"
        [ -n "$variantParent" ]
        variantArches="${parentRepoToArches[$variantParent]:-}"
        
        echo
        cat <<-EOE
Tags: $(join ', ' "${versionAliases[@]}")
Architectures: $(join ', ' $variantArches)
GitCommit: $commit
Directory: $version
EOE
        constraints="$(bashbrew cat --format '{{ .TagEntry.Constraints | join ", " }}' "https://github.com/docker-library/official-images/raw/master/library/$variantParent" 2>/dev/null || true)"
        [ -z "$constraints" ] || echo "Constraints: $constraints"

        for variant in postgres; do
            [ -f "$version/$variant/Dockerfile" ] || continue
            commit="$(dirCommit "$version/$variant")"
            variantAliases=( "${versionAliases[@]/%/-$variant}" )
            variantAliases=( "${variantAliases[@]//latest-/}" )
            variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$version/$variant/Dockerfile")"
            [ -n "$variantParent" ]
            
            echo
            cat <<-EOE
Tags: $(join ', ' "${variantAliases[@]}")
Architectures: $(join ', ' $variantArches)
GitCommit: $commit
Directory: $version/$variant
EOE
            constraints="$(bashbrew cat --format '{{ .TagEntry.Constraints | join ", " }}' "https://github.com/docker-library/official-images/raw/master/library/$variantParent" 2>/dev/null || true)"
            [ -z "$constraints" ] || echo "Constraints: $constraints"
        done
    fi
done
