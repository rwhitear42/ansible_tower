FROM nginx:alpine
RUN mkdir -p /etc/ssl
COPY awx.crt /etc/ssl/awx.crt
COPY awx.key /etc/ssl/awx.key
COPY nginx.conf /etc/nginx/nginx.conf
