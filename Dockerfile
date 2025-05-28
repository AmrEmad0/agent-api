FROM agnohq/python:3.12

ARG USER=app
ARG APP_DIR=/app
ENV APP_DIR=${APP_DIR}

# Create user and home directory
RUN groupadd -g 61000 ${USER} \
  && useradd -g 61000 -u 61000 -ms /bin/bash -d ${APP_DIR} ${USER}

WORKDIR ${APP_DIR}

# Copy requirements.txt
COPY requirements.txt ./

# Install requirements
RUN uv pip sync requirements.txt --system

# Copy project files
COPY . .

# Debug: Show what was copied
RUN echo "=== Files in /app ===" && \
    find /app -type f -name "*.sh" && \
    echo "=== Contents of scripts directory ===" && \
    ls -la /app/scripts/ && \
    echo "=== Checking entrypoint.sh ===" && \
    ls -la /app/scripts/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /app/scripts/entrypoint.sh

# Set permissions for the /app directory
RUN chown -R ${USER}:${USER} ${APP_DIR}

# Switch to non-root user
USER ${USER}

ENTRYPOINT ["/app/scripts/entrypoint.sh"]
CMD ["chill"]
