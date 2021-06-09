FROM node:lts-alpine AS build
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN yarn
RUN yarn run build

FROM nginx:stable-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/nginx.conf
COPY --from=build /app/build /app
CMD ["nginx", "-g", "daemon off;"]
