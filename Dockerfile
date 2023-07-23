# https://github.com/lizrice/libbpfgo-beginners/pull/5/commits/95c92b8db70565d55a9030aec45b76ea153803f1
FROM golang:1.20-bullseye

# Download development environment.
RUN apt-get update && \
    apt-get install -y \
        clang \
        llvm \
        libbpf-dev \
        libelf-dev

# Setup working directory.
RUN mkdir -p /app
WORKDIR /app

# https://github.com/lizrice/libbpfgo-beginners/pull/5/commits/39805fc690b96a30ca9866220eae6a2efe11e6cb
# Execute build command.
ENTRYPOINT ["/usr/bin/make", "all"]
