# Linter

[![Docker](https://images.microbadger.com/badges/image/electrocucaracha/linter.svg)](http://microbadger.com/images/electrocucaracha/linter)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

### Usage

Use this ```Dockerfile``` to build a base image for your unit tests
in [Concourse CI](http://concourse.ci/).

Here is an example of a Concourse
[job](https://concourse-ci.org/jobs.html) that uses
```electrocucaracha/linter``` image to run a bunch of containers in a
task, and then runs the integration test suite.


```yaml
  - name: linting
    serial: true
    plan:
      - get: src
        trigger: true
        params: {depth: 1}
      - in_parallel:
          - task: tox
            config:
              platform: linux
              image_resource:
                type: docker-image
                source:
                  repository: electrocucaracha/linter
              inputs:
                - name: code
              run:
                dir: src
                path: /usr/local/bin/linter.sh
                params:
                   RELENG_LINTER_TOOL: tox
          - task: shellcheck
            config:
              platform: linux
              image_resource:
                type: docker-image
                source:
                  repository: electrocucaracha/linter
              inputs:
                - name: code
              run:
                dir: src
                path: /usr/local/bin/linter.sh
                params:
                   RELENG_LINTER_TOOL: shellcheck
          - task: hadolint
            config:
              platform: linux
              image_resource:
                type: docker-image
                source:
                  repository: electrocucaracha/linter
              inputs:
                - name: code
              run:
                dir: src
                path: /usr/local/bin/linter.sh
                params:
                   RELENG_LINTER_TOOL: hadolint
          - task: golangci-lint
            config:
              platform: linux
              image_resource:
                type: docker-image
                source:
                  repository: electrocucaracha/linter
              inputs:
                - name: code
              run:
                dir: src
                path: /usr/local/bin/linter.sh
                params:
                   RELENG_LINTER_TOOL: golangci-lint
```
