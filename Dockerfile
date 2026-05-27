FROM hashicorp/terraform:1.12.0

RUN apk add --no-cache bash curl

WORKDIR /workdir

ENTRYPOINT []
CMD ["/bin/bash"]
