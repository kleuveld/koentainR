# About

This repo contains a docker file to build my koentainR image, 
which builds RMarkdown documents.

It used to be called rmarkdown2pdf because it could render pdfs, 
but now it doesn't.

When building the docker image, it is provided with a lock file, 
and it installs all packages in a library in the image in `/renv/library`.
Each project that uses this image thus has its own branch in this repo,
which has its own lockfile. Everytime the lockfile is updated, 
the image should be re-built.
Images are automatically built on ghcr.io upon a push in any non dev branch,
and tagged with <version>-<branch>.
The version number is meant to be the base version, hardcoded in the github action.

# Running the container locally

Make sure docker is installed, and run: 

```
docker build -t koentainr .

```

Then, to compile the example PDF:

```
docker run --rm -v path/to/project:/doc koentainR myrmd.Rmd

```

If the file is named "index.Rmd" (case-sensitive, for now), bookdown will be used
to render the file: 

```

docker run --rm -v /home/koen/git/r_cheatsheet:/doc koentainr index.Rmd


```



Or, to run interactively:

```
docker run -it --entrypoint /bin/bash koentainr 

```

To add git support, make sure a private key is in home and:

```
docker run -it --entrypoint /bin/bash -v /home/koen/.shh:/root/.shh  koentainr 

```



# Pushing changes to GHCR

When changes are pushed to any branch except dev, and dev-*, 
github will build a new image!

They will be tagged with `0.3_<branch>`

# Pulling the image

## Log in:

Get a Personal access token, and get ready to paste in when prompted:
```
# 1) read silently into a variable (token will not be echoed)
read -s -p "GHCR token: " CR_PAT; echo

# 2) login to GHCR using the token (replace 'kleuveld' if different)
echo "$CR_PAT" | docker login ghcr.io -u kleuveld --password-stdin

# 3) pull the image (replace <branch> with the branch tag you want)
docker pull ghcr.io/kleuveld/koentainr:0.3.r_cheatsheet

# 4) cleanup the in-memory token
unset CR_PAT

# 5) optional: remove docker credentials from disk
docker logout ghcr.io

``` 

## Pull

```
docker pull ghcr.io/kleuveld/koentainr:0.3.<branch>


```

To use the image:

```

docker run --rm -v /home/koen/git/r_cheatsheet:/doc ghcr.io/kleuveld/koentainr:0.3.r_cheatsheet index.Rmd


```

# Using it in Github Actions

```
          - name: Run the build process with Docker
            run: docker run --rm -v ${{ github.workspace }}:/doc ghcr.io/kleuveld/koentainr:0.3.r_cheatsheet index.Rmd

```

