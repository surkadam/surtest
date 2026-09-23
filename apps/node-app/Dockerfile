FROM node:18-bookworm-slim

WORKDIR /app

COPY package.json .
RUN npm install --silent

COPY index.js .

EXPOSE 3000

# VULN: running as root (no USER directive)test
CMD ["node", "index.js"]
