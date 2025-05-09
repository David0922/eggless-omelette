FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq
RUN apt-get upgrade -qq
RUN apt-get install -qq \
  nginx \
  python3-pip \
  python3.12
RUN pip install --break-system-packages certbot certbot-nginx
CMD ["certbot", "certonly", "--nginx", "--agree-tos", "--force-renewal", "--register-unsafely-without-email", "--domain", "goodbye-world.mofu.dev"]
