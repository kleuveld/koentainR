# About

This repo contains a docker file to build my koentainR image, 
which builds RMarkdown documents.

It used to be called rmarkdown2pdf because it could render pdfs, 
but now it doesn't.

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
docker run -it --entrypoint /bin/bash -v %cd%:/doc koentainr 


```



# Pushing changes to Docker Hub

To push it to docker hub, follow [instructions](https://docs.docker.com/get-started/04_sharing_app/):

```
docker tag koentainr koenleuveld/koentainr:0.2.11
docker tag koentainr koenleuveld/koentainr:latest

docker push koenleuveld/koentainr:latest
docker tag koentainr koenleuveld/koentainr:0.2.11
r

```


# Using it in Github Actions

```
          - name: Run the build process with Docker
            run: docker run --rm -v ${{ github.workspace }}:/doc docker.io/koenleuveld/koentainr:0.2.1 myrmd.Rmd

```


The container comes with renv.


The container uses `/root/.cache/R/renv/cache` as a cache for packages installed
through renv.
Make sure to map it to a drive on your local host machine, 
so you only have to build the packages once.

```

docker run -it -v C:\temp\renv_docker_cache:/root/.cache/R/renv/cache -v %cd%:/doc rmarkdown2pdf 

```