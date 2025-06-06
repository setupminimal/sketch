FROM ghcr.io/boldsoftware/sketch:99a2e4afe316b3c6cf138830dbfb7796

ARG GIT_USER_EMAIL
ARG GIT_USER_NAME

RUN git config --global user.email "$GIT_USER_EMAIL" && \
    git config --global user.name "$GIT_USER_NAME" && \
    git config --global http.postBuffer 524288000

LABEL sketch_context="45ae7c2a65560701f1da47223747d1e8d9e62d75b5fc28b51d3a5f6afb0daa3e"
COPY . /app
RUN rm -f /app/tmp-sketch-dockerfile

WORKDIR /app
RUN if [ -f go.mod ]; then go mod download; fi

# Switch to lenient shell so we are more likely to get past failing extra_cmds.
SHELL ["/bin/bash", "-uo", "pipefail", "-c"]

RUN echo "Setting up a minimal Go test project environment"

# Install any Go-specific testing tools
RUN go install github.com/stretchr/testify@latest || true

# Basic Python environment setup (optional, will continue if it fails)
RUN pip3 install pytest pytest-cov || true

# Run initial setup if needed
RUN if [ -f "Makefile" ]; then make setup || true; fi

# Switch back to strict shell after extra_cmds.
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

CMD ["/bin/sketch"]
