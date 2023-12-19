# Use the official Node.js 14 image as the base image
FROM node:alpine AS builder


# Set the working directory inside the container
WORKDIR /app

# Set the environment variable
ENV NODE_ENV=production

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the entire project to the container
COPY . .

# Build the React app
RUN npm run build

FROM nginx

# Copying built assets from builder
COPY --from=builder /app/build /usr/share/nginx/html

# Copying our nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /usr/share/nginx/html

COPY ./env_config.sh .

COPY .env .

RUN addgroup --gid 1000 bp-reactjs-boilerplate && \
    adduser --uid 1001 --gid 1000 --disabled-password --gecos "" bp-reactjs-boilerplate && \
    chown -R bp-reactjs-boilerplate:bp-reactjs-boilerplate /usr/share/nginx/html && \
    chown -R bp-reactjs-boilerplate:bp-reactjs-boilerplate /var && \
    touch /var/run/nginx.pid && \
    chown -R bp-reactjs-boilerplate:bp-reactjs-boilerplate /var/run/nginx.pid && \
    echo 'bp-reactjs-boilerplate ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER bp-reactjs-boilerplate

RUN chmod +x env_config.sh

CMD ["/bin/bash", "-c", "/usr/share/nginx/html/env_config.sh && nginx -g \"daemon off;\""]
