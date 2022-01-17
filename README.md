# About this Repo

This is the Git repo of the official Docker image for [geonetwork](https://registry.hub.docker.com/_/geonetwork/). See the
Hub page for the full readme on how to use the Docker image and for information
regarding contributing and issues.

The full readme is generated over in [docker-library/docs](https://github.com/docker-library/docs),
specificially in [docker-library/docs/geonetwork](https://github.com/docker-library/docs/tree/master/geonetwork).

# Default branch

Default branch has been renamed from `master` to `main`. To update it in your local repository follow these steps:
```bash
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```

