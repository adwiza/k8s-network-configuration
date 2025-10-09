# Use official nginx build dependencies image for compiling
FROM nginx:1.25-alpine as builder

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    pcre-dev \
    zlib-dev \
    linux-headers \
    openssl-dev \
    wget

# Get nginx source code for the exact version
ARG NGINX_VERSION=1.25.2
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz

WORKDIR /nginx-${NGINX_VERSION}

# Configure with stream module as dynamic
RUN ./configure \
    --with-compat \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-http_ssl_module

# Compile only the modules as dynamic
RUN make modules

# -------------------------------------------------------------------
# Build final image
FROM nginx:1.25-alpine

# Copy your custom nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Copy compiled stream module .so from builder stage
COPY --from=builder /nginx-1.25.2/objs/ngx_stream_module.so /etc/nginx/modules/

# Create modules directory (usually exists, but just in case)
RUN mkdir -p /etc/nginx/modules

# Copy nginx.conf example (optional, you can mount your own config)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose ports (e.g., 80 for HTTP, 443 for HTTPS, and  stream ports as needed)
EXPOSE 80 443 12345

CMD ["nginx", "-g", "daemon off;"]
