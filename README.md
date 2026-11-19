# About this Repo

This is the Git repo of the official Docker image for [geonetwork](https://registry.hub.docker.com/_/geonetwork/). See the
Hub page for the full readme on how to use the Docker image and for information
regarding contributing and issues.

The full readme is generated over in [docker-library/docs](https://github.com/docker-library/docs),
specifically in [docker-library/docs/geonetwork](https://github.com/docker-library/docs/tree/master/geonetwork).

# Updating the Docker Official Image manifest

The `geonetwork-library.txt` file is the manifest submitted to [docker-library/official-images](https://github.com/docker-library/official-images) to publish new GeoNetwork versions on Docker Hub.

## Before generating: update generate-stackbrew-library.sh

When releasing a new patch version, edit `generate-stackbrew-library.sh` first and merge the change to `main`:

- Add the new version to the `aliases` array with its Docker Hub tag aliases (e.g. `4.4.11` -> `4.4 4 latest`).
- Add the superseded patch version to the `dirExclude` array so it is skipped in the manifest.

## Automated: GitHub Actions workflow

Once the release PRs are merged to `main`, the **Open official-images PR** workflow
(`.github/workflows/official-images-pr.yml`) generates the manifest and opens the PR
against `docker-library/official-images` from the `GeoCat/official-images` fork.

To run it, go to the **Actions** tab, select **Open official-images PR** and click **Run workflow**.
The `draft` option is enabled by default, so you can review the PR before marking it ready.

The workflow needs a repository secret named `OFFICIAL_IMAGES_TOKEN`: a fine-grained personal access
token of an account with write access to `GeoCat/official-images`. Use `GeoCat` as the resource owner,
select only the `GeoCat/official-images` repository and grant `Contents` and `Pull requests` read and write.

A fine-grained token may not be allowed to open a PR on `docker-library/official-images`, which is outside
its owner. If that happens the workflow still pushes the branch to the fork, fails, and writes a link in the
job summary to open the PR by hand. A classic token with the `public_repo` scope avoids the limitation.

If the manifest has no changes the workflow does nothing. If a PR for the same branch is already open,
the workflow updates its branch instead of opening a second PR.

The sections below describe the manual process, which still works if the workflow is not available.

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

Run this from a regular clone of the repository (not a git worktree) after the release PRs are merged, so the
`GitCommit` values in the manifest are the merge commits on `main`. The generated file is only an
intermediate input for the official-images PR and does not need to be committed to this repository.

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
