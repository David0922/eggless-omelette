FROM nginx:stable-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY ./stream.conf /etc/nginx/stream.conf
RUN echo 'include /etc/nginx/stream.conf;' >> /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
