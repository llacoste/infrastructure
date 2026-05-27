FROM hashicorp/terraform:1.12.0

ARG TFLINT_VERSION=0.62.1

RUN apk add --no-cache bash curl unzip \
    && arch="$(uname -m)" \
    && case "$arch" in \
         aarch64) tflint_arch=arm64 ;; \
         x86_64)  tflint_arch=amd64 ;; \
         *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
       esac \
    && curl -fsSL -o /tmp/tflint.zip \
       "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${tflint_arch}.zip" \
    && unzip /tmp/tflint.zip -d /usr/local/bin \
    && rm /tmp/tflint.zip \
    && tflint --version

WORKDIR /workdir

ENTRYPOINT []
CMD ["/bin/bash"]
