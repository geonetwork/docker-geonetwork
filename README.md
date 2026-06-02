# About this Repo

This is the Git repo of the official Docker image for [geonetwork](https://registry.hub.docker.com/_/geonetwork/). See the
Hub page for the full readme on how to use the Docker image and for information
regarding contributing and issues.

The full readme is generated over in [docker-library/docs](https://github.com/docker-library/docs),
specifically in [docker-library/docs/geonetwork](https://github.com/docker-library/docs/tree/master/geonetwork).

# Updating the Docker Official Image manifest

The `geonetwork-library.txt` file is the manifest submitted to [docker-library/official-images](https://github.com/docker-library/official-images) to publish new GeoNetwork versions on Docker Hub.

## Before generating: update generate-stackbrew-library.sh

When releasing a new patch version, edit `generate-stackbrew-library.sh` first:

- Add the new version to the `aliases` array with its Docker Hub tag aliases (e.g. `4.4.11` -> `4.4 4 latest`).
- Add the superseded patch version to the `dirExclude` array so it is skipped in the manifest.

## Generating geonetwork-library.txt

The generation script requires Bash 4+ and `bashbrew`. Use the provided `Dockerfile.stackbrew` to avoid installing those dependencies locally.

Build the helper image once (or after `bashbrew` version changes):

```bash
docker build -f Dockerfile.stackbrew -t geonetwork-stackbrew .
```

Generate the manifest:

```bash
docker run --rm -v "$(pwd):/work" geonetwork-stackbrew > geonetwork-library.txt
```

Commit `geonetwork-library.txt` to this repository so it can be used as a reference.

## Creating the PR to docker-library/official-images

1. Fork [docker-library/official-images](https://github.com/docker-library/official-images) if you have not already. In your local clone of the fork, add the upstream remote:
   ```bash
   git remote add upstream https://github.com/docker-library/official-images.git
   ```

2. Sync with upstream `master` and create a new branch:
   ```bash
   git fetch upstream
   git checkout -b update-geonetwork-<version> upstream/master
   ```

3. Copy the generated manifest into `library/geonetwork` and commit:
   ```bash
   cp /path/to/docker-geonetwork/geonetwork-library.txt library/geonetwork
   git add library/geonetwork
   git commit -m "Update GeoNetwork to <version>"
   ```

4. Push to your fork and open the PR:
   ```bash
   git push origin update-geonetwork-<version>
   ```
   Open a pull request from your fork's branch against the `master` branch of `docker-library/official-images`.

# Default branch

Default branch has been renamed from `master` to `main`. To update it in your local repository:
```bash
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```
