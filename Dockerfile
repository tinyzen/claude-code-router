FROM node:20-alpine

ARG VERSION=latest

RUN npm install -g @musistudio/claude-code-router@$VERSION

# Create default configuration directory and file
RUN mkdir -p /root/.claude-code-router && \
    echo '{"HOST": "0.0.0.0", "PORT": 3456, "APIKEY": "your-secret-key", "Providers": [], "Router": {}}' > /root/.claude-code-router/config.json

VOLUME /root/.claude-code-router

EXPOSE 3456

ENTRYPOINT ["ccr"]

CMD ["start"]
