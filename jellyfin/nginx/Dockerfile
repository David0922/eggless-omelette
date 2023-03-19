FROM nginx:stable-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
