ARG PYTHON_BASE_IMAGE=quay.io/relrod/ansible-python-base-stream9:latest
ARG PYTHON_BUILDER_IMAGE=quay.io/relrod/ansible-python-builder-stream9:latest

FROM $PYTHON_BUILDER_IMAGE as builder
# =============================================================================
ARG ZUUL_SIBLINGS

# build this library (meaning ansible-builder)
COPY . /tmp/src
RUN assemble
FROM $PYTHON_BASE_IMAGE
# =============================================================================

COPY --from=builder /output/ /output
# building EEs require the install-from-bindep script, but not the rest of the /output folder
RUN /output/install-from-bindep && find /output/* -not -name install-from-bindep -exec rm -rf {} +
RUN pip install wheel

# move the assemble scripts themselves into this container
COPY --from=builder /usr/local/bin/assemble /usr/local/bin/assemble
COPY --from=builder /usr/local/bin/get-extras-packages /usr/local/bin/get-extras-packages
