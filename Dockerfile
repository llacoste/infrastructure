# check=skip=InvalidDefaultArgInFrom
# TERRAFORM_VERSION, TFLINT_VERSION, and JUST_VERSION are required build-args
# sourced from .tool-versions by the justfile.
ARG TERRAFORM_VERSION
FROM hashicorp/terraform:${TERRAFORM_VERSION}

ARG TFLINT_VERSION
ARG JUST_VERSION

RUN apk add --no-cache bash curl unzip \
    && arch="$(uname -m)" \
    && case "$arch" in \
         aarch64) tflint_arch=arm64; just_arch=aarch64 ;; \
         x86_64)  tflint_arch=amd64; just_arch=x86_64 ;; \
         *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
       esac \
    && curl -fsSL -o /tmp/tflint.zip \
       "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${tflint_arch}.zip" \
    && unzip /tmp/tflint.zip -d /usr/local/bin \
    && rm /tmp/tflint.zip \
    && curl -fsSL -o /tmp/just.tar.gz \
       "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${just_arch}-unknown-linux-musl.tar.gz" \
    && tar -xzf /tmp/just.tar.gz -C /usr/local/bin just \
    && rm /tmp/just.tar.gz \
    && tflint --version \
    && just --version

WORKDIR /workdir

ENTRYPOINT []
CMD ["/bin/bash"]
