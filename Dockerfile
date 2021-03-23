FROM ubuntu:hirsute as builder

ENV SHELLCHECK_VERSION=v0.7.1
ENV HADOLINT_VERSION=v1.22.1
ENV GOLANGCI_LINT_VERSION=v1.38.0
ENV KUBE_LINTER_VERSION=0.1.6

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  wget=1.21-1ubuntu3 \
  cabal-install=3.0.0.0-3build1 \
  ghc=8.8.4-2 \
  haskell-stack=2.3.3-1 \
  libghc-regex-tdfa-dev=1.3.1.0-2build2 \
  libghc-aeson-dev=1.4.7.1-2build2 \
  libghc-quickcheck2-dev=2.13.2-1build3 \
  libghc-diff-dev=0.4.0-1build2 && \
  rm -rf /var/lib/apt/lists/*

# Fetch source code
RUN wget -c https://github.com/koalaman/shellcheck/archive/${SHELLCHECK_VERSION}.tar.gz -O - | tar -xz -C /opt
RUN wget -c https://github.com/hadolint/hadolint/archive/${HADOLINT_VERSION}.tar.gz -O - | tar -xz -C /opt

# Build binaries
# hadolint ignore=DL3003
RUN cd /opt/shellcheck-${SHELLCHECK_VERSION#v}/ && cabal install --dependencies-only && cabal install
# hadolint ignore=DL3003
RUN cd /opt/hadolint-${HADOLINT_VERSION#v}/ && stack install
# hadolint ignore=DL3003
RUN cd /; wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s $GOLANGCI_LINT_VERSION
RUN wget -c https://github.com/stackrox/kube-linter/releases/download/$KUBE_LINTER_VERSION/kube-linter-linux.tar.gz -O - | tar -xz -C /opt

FROM ubuntu:hirsute

ENV PATH="/usr/lib/go-1.15/bin/:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
  tox=3.21.4-1 golang-1.15=1.15.8-1ubuntu3 && \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local/bin/hadolint /usr/local/bin/hadolint
COPY --from=builder /root/.cabal/bin/shellcheck /usr/local/bin/shellcheck
COPY --from=builder /bin/golangci-lint /usr/local/bin/golangci-lint
COPY --from=builder /opt/kube-linter /usr/local/bin/kube-linter

COPY ./linter_entrypoint.sh /usr/local/bin/linter.sh

ENTRYPOINT ["/usr/local/bin/linter.sh"]
