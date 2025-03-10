FROM node:lts-alpine AS build
RUN mkdir /work-dir
ADD . /work-dir
WORKDIR /work-dir
RUN npm install --global pnpm@latest-10
RUN pnpm install --force
RUN pnpm build

FROM nginx:stable-alpine-slim
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/nginx.conf
COPY --from=build /work-dir/dist /app
CMD ["nginx", "-g", "daemon off;"]
