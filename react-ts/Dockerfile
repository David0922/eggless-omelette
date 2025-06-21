FROM node:lts-alpine AS build
RUN npm install --global pnpm@latest-10
RUN mkdir /work-dir
ADD . /work-dir
WORKDIR /work-dir
RUN rm -rf ./node_modules
RUN pnpm install
RUN pnpm build

FROM nginx:stable-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/nginx.conf
COPY --from=build /work-dir/dist /app
CMD ["nginx", "-g", "daemon off;"]
