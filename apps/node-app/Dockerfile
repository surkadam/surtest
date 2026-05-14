FROM node:12-alpine

WORKDIR /app

COPY package.json .
RUN npm install --silent

COPY index.js .

EXPOSE 3000

# VULN: running as root (no USER directive)
CMD ["node", "index.js"]
