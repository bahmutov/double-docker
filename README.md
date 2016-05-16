# double-docker

[![NPM][double-docker-icon] ][double-docker-url]

[![Build status][double-docker-ci-image] ][double-docker-ci-url]
[![semantic-release][semantic-image] ][semantic-url]

> NPM installs goes into the base docker image (based on SHA of package.json)
> Tests and builds are now both *repeatable and super fast*

```
local command                  Docker image

node <version>          ---->  alpine/mhart-<version>
                                     |
package.json <SHASUM>                V
npm install             ---->  dd-deps-<name>-<version>:<SHASUM>      clean, slow, rare
                                     |
src/                                 V
npm test                ---->  dd-child-<name>-<version>              FAST, often
```

## The problem

The CI should build your project in isolation, thus it should run `npm install` from an empty
folder. This takes some time. If we could separate the install from testing or building, we could
run the tests really quickly.

We also want to follow the same approach when working locally. For example 
[autochecker](https://github.com/victorbjelkholm/autochecker) tests your Node project
in the separate Docker containers, yet does not run the `npm install` from the *clean folder*
on each build, instead relying on previous contents cache.

## Solution

1. Grab the SHA of `npm-shrinkwrap.json` or `package.json` file
2. Build `<project-name-node-version-SHA>` docker image with `npm install` inside
   This docker image has the NPM dependencies installed and can be reused
3. Build new docker image based on the previous image with the source code from the
   current folder. The docker image runs `npm test` command.

That's it. You can work locally like this, or put the commands on CI and the builds become
very very fast.

Don't forget to put `.dockerignore` file in the root of your project with `/node_modules`
line to prevent copying the large folder for nothing.

## Available scripts

Instead of running `npm install test` you can run [install-and-test.sh](install-and-test.sh)

Instead of running `npm install build` you can run [install-and-build.sh](install-and-build.sh)

To clear all containers and docker images run 
[utils/rm-docker-images.sh](utils/rm-docker-images.sh)

## The timing

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
$ cd test
$ time ./install-and-test.sh
... package.json file has SHA 808de4d5ca619670e34b26d6e93bcaa7a4e2da81
... builds double-docker-npm-deps:808de4d5ca619670e34b26d6e93bcaa7a4e2da81
... with NPM dependencies
... builds double-docker:0.12 on top of double-docker-npm-deps:808de4d ...
... runs npm test in double-docker:0.12
real  0m28.460s
user  0m0.770s
sys 0m0.346s
```

So we lost 10 seconds because of building two Docker images the first time.
But any run after the first one is very fast

```sh
$ cd test
$ time ./install-and-test.sh
... first docker image with deps is already there, no changes
... building second docker image by copying files
... runs npm test in double-docker:0.12
real  0m1.264s
user  0m0.108s
sys   0m0.053s
```

But now clone the same repo somewhere else on the local machine. Without running
`npm install` run tests.

```sh
$ git clone <repo> double-docker
$ cd test-npm-layers/test
$ time ./install-and-test.sh
... pulls docker deps from local Docker registry
... runs tests
real  0m0.941s
user  0m0.130s
sys 0m0.073s
```

Nice!

We could probably make it even faster by mounting the current working folder into the
container. But having an actual *built* container allows us one more trick - the tests
can be executed on *a separate machine*. Thus you can keep working locally and when running
the script, the built image could be pulled and executed from any other CI machine.

## Removing extra containers and images

Created docker containers and images are prefixed with `dd-`.
To remove them, run the script [rm-docker-images.sh](rm-docker-images.sh)

### Small print

Author: Gleb Bahmutov &copy; 2016

* [@bahmutov](https://twitter.com/bahmutov)
* [glebbahmutov.com](http://glebbahmutov.com)
* [blog](http://glebbahmutov.com/blog/)

License: MIT - do anything with the code, but don't blame me if it does not work.

Spread the word: tweet, star on github, etc.

Support: if you find any problems with this module, email / tweet /
[open issue](https://github.com/bahmutov/double-docker/issues) on Github

## MIT License

Copyright (c) 2016 Gleb Bahmutov

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

[double-docker-icon]: https://nodei.co/npm/double-docker.png?downloads=true
[double-docker-url]: https://npmjs.org/package/double-docker
[double-docker-ci-image]: https://travis-ci.org/bahmutov/double-docker.png?branch=master
[double-docker-ci-url]: https://travis-ci.org/bahmutov/double-docker
[semantic-image]: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
[semantic-url]: https://github.com/semantic-release/semantic-release
