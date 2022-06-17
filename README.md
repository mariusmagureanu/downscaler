K8s cluster downscaler
----------------------

This project is a poor man's attempt to reduce cost with running clusters. The idea behind it is to automatically scale up/down the number of worker nodes.
It is assumed that the clusters are used within certain time frames, thus not being needed outside them, e.g. evenings,weekends...etc

## What is it?

The downscaler is a lambda function triggered at specific times. There are two available schedules to be set, one for upscaling and another for downscaling.

## Build the downscaler

Run the following in the repository's root directory:

```sh
$ make
```

This will build the source code under ``src/`` and create a ``source.zip`` file.

## Deploy the downscaler
