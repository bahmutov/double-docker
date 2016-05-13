# double Docker

Builds separate image with NPM installs based on package.json MD5
Builds final image with the current code for testing

## Why

Installing NPM dependencies takes a long time. For example here, with
express, babel and babel-cli

```sh
$ node -v
v6.0.0
$ npm -v
3.8.6
$ time npm install
real  0m19.302s
user  0m10.153s
sys   0m2.957s
```

Build locally once (which includes testing right now)

```sh
$ time ./build-docker-images.sh
... package.json file has SHA 808de4d5ca619670e34b26d6e93bcaa7a4e2da81
... builds test-autochecker-npm-deps:808de4d5ca619670e34b26d6e93bcaa7a4e2da81
... with NPM dependencies
... builds test-autochecker:0.12 on top of test-autochecker-npm-deps:808de4d ...
... runs npm test in test-autochecker:0.12
real  0m28.460s
user  0m0.770s
sys 0m0.346s
```

So we lost 10 seconds because of building two Docker images the first time.
But any run after the first one is very fast

```sh
$ time ./build-docker-images.sh
... first docker image with deps is already there, no changes
... building second docker image by copying files
... runs npm test in test-autochecker:0.12
real  0m1.264s
user  0m0.108s
sys   0m0.053s
```

But now clone the same repo somewhere else on the local machine. Without running
`npm install` run tests.

```sh
$ git clone <repo> test-npm-layers
$ cd test-npm-layers
$ time ./build-docker-images.sh
... pulls docker deps from local Docker registry
... runs tests
real  0m0.941s
user  0m0.130s
sys 0m0.073s
```

Nice!

We could probably make it even faster by mounting the current working folder into the
container. But having an actual *built* containe allows us one more trick - the tests
can be executed on *separate machine*. Thus you can keep working locally and when running
the script, the built image could be pulled and executed from any other CI machine.

## Removing extra containers and images

Created docker containers and images are prefixed with `dd-`.
To remove them, run the script [rm-docker-images.sh](rm-docker-images.sh)
