# Build environment
FROM swift:5.1.1-bionic AS build

#RUN apt-get update \
#  && apt-get install -y --force-yes software-properties-common libssl-dev libz-dev libnghttp2-dev libunwind8-dev \
#  && apt-get dist-upgrade -y --force-yes \
#  && apt-get autoremove -y \
#  && apt-get clean -y \
#  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the package manifest.
# Don't copy actual sources yet to avoid invalidating the build cache.
RUN mkdir -p /root/docker-caching-test
WORKDIR /root/docker-caching-test
COPY Package.swift /root/docker-caching-test/

RUN swift package resolve

COPY Tests Tests

ARG config=debug
RUN mkdir -p Sources/docker-caching-test && \
  touch Sources/docker-caching-test/docker_caching_test.swift && \
  swift build -c $config && \
  stat .build/debug/CNIOBoringSSL.build/module.modulemap && \
  stat .build/debug/CNIOBoringSSL.build/crypto/crypto.c.d && \
  stat .build/debug/CNIOBoringSSL.build/crypto/crypto.c.o && \
  echo "test" && \
  tar czf build.tgz -H posix .build

RUN stat .build/debug/CNIOBoringSSL.build/module.modulemap && \
  stat .build/debug/CNIOBoringSSL.build/crypto/crypto.c.d && \
  stat .build/debug/CNIOBoringSSL.build/crypto/crypto.c.o && \
  rm -rf .build

RUN tar xzf build.tgz -p --atime-preserve && \
  stat .build/debug/CNIOBoringSSL.build/module.modulemap && \
  stat .build/debug/CNIOBoringSSL.build/crypto/crypto.c.d && \
  stat .build/debug/CNIOBoringSSL.build/crypto/crypto.c.o && \
  swift build -c $config
RUN ls -la .build/debug/CNIOBoringSSL.build/crypto
#RUN du -sk .build/debug/* | sort -nr

# Now, copy the actual sources and build them.
COPY Sources Sources

#RUN swift build -c $config
