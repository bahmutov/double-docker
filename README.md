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

So we lost 10 seconds because of building two Docker images.
But now clone the same repo somewhere else on the local machine.

