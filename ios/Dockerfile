#######
# Build swiftlint from sources
#######
FROM swift as swiftLintBuilder

ENV SWIFTLINT_REVISION="master"

# Install SwiftLint
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    swift build --configuration release --static-swift-stdlib && \
    mv `swift build --configuration release --static-swift-stdlib --show-bin-path`/swiftlint /usr/bin && \
    cd .. && \
    rm -rf SwiftLint

# Print Installed SwiftLint Version
RUN swiftlint version

#######
# Build final image with added swiflint binary build from previous stage
#######
FROM ubuntu:16.04
MAINTAINER Jakub Knejzlik <jakub.knejzlik@inloopx.com>
MAINTAINER Radim Halfar <radim.halfar@inloopx.com>

# Install dependencies
RUN apt-get update && apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties software-properties-common libffi-dev nodejs rubygems ruby-dev make gcc git

# Update git to newer version
RUN add-apt-repository ppa:git-core/ppa
RUN apt-get update && apt-get install -y git

# Install Ruby
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/.rbenv
ENV PATH /usr/local/.rbenv/bin:$PATH
RUN eval "$(rbenv init -)"

# Install ruby build
RUN git clone https://github.com/rbenv/ruby-build.git /usr/local/.rbenv/plugins/ruby-build
ENV PATH /usr/local/.rbenv/plugins/ruby-build/bin:$PATH
RUN git clone https://github.com/rbenv/rbenv-gem-rehash.git /usr/local/.rbenv/plugins/rbenv-gem-rehash

# Setup ruby global version
RUN rbenv install 2.4.1
RUN rbenv global 2.4.1

# Setup bash as default shell
RUN chsh -s /bin/bash

# installing plugins
RUN gem install bundler rake
RUN gem install danger-gitlab
RUN gem install specific_install
RUN gem specific_install https://github.com/radimhalfar/danger-jira


# Swift
# Install related packages and set LLVM 3.8 as the compiler
RUN apt-get -q update && \
    apt-get -q install -y \
    make \
    libc6-dev \
    clang-3.8 \
    curl \
    libedit-dev \
    libpython2.7 \
    libicu-dev \
    libssl-dev \
    libxml2 \
    tzdata \
    git \
    libcurl4-openssl-dev \
    pkg-config \
    && update-alternatives --quiet --install /usr/bin/clang clang /usr/bin/clang-3.8 100 \
    && update-alternatives --quiet --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100 \
    && rm -r /var/lib/apt/lists/*    

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little
ARG SWIFT_PLATFORM=ubuntu16.04
ARG SWIFT_BRANCH=swift-4.1.3-release
ARG SWIFT_VERSION=swift-4.1.3-RELEASE

ENV SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_VERSION=$SWIFT_VERSION

# Download GPG keys, signature and Swift package, then unpack, cleanup and execute permissions for foundation libs
RUN SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz \
    && curl -fSsL $SWIFT_URL -o swift.tar.gz \
    && curl -fSsL $SWIFT_URL.sig -o swift.tar.gz.sig \
    && export GNUPGHOME="$(mktemp -d)" \
    && set -e; \
    for key in \
    # pub   rsa4096 2017-11-07 [SC] [expires: 2019-11-07]
    # 8513444E2DA36B7C1659AF4D7638F1FB2B2B08C4
    # uid           [ unknown] Swift Automatic Signing Key #2 <swift-infrastructure@swift.org>
    8513444E2DA36B7C1659AF4D7638F1FB2B2B08C4 \
    # pub   4096R/91D306C6 2016-05-31 [expires: 2018-05-31]
    #       Key fingerprint = A3BA FD35 56A5 9079 C068  94BD 63BC 1CFE 91D3 06C6
    # uid                  Swift 3.x Release Signing Key <swift-infrastructure@swift.org>
    A3BAFD3556A59079C06894BD63BC1CFE91D306C6 \
    # pub   4096R/71E1B235 2016-05-31 [expires: 2019-06-14]
    #       Key fingerprint = 5E4D F843 FB06 5D7F 7E24  FBA2 EF54 30F0 71E1 B235
    # uid                  Swift 4.x Release Signing Key <swift-infrastructure@swift.org>          
    5E4DF843FB065D7F7E24FBA2EF5430F071E1B235 \
    ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done \
    && gpg --batch --verify --quiet swift.tar.gz.sig swift.tar.gz \
    && tar -xzf swift.tar.gz --directory / --strip-components=1 \
    && rm -r "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz \
    && chmod -R o+r /usr/lib/swift 
# Swift end

# Swiftlint
COPY --from=swiftLintBuilder /usr/bin/swiftlint /usr/bin
RUN gem install danger-swiftlint

ENV WORKDIR="/danger"

RUN danger --version

WORKDIR ${WORKDIR}

ENTRYPOINT [""]