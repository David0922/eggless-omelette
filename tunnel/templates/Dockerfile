FROM ubuntu:24.04
RUN mkdir /work-dir
ADD . /work-dir
RUN chmod +x /work-dir/provision.sh
RUN /work-dir/provision.sh
CMD ["nginx", "-g", "daemon off;"]
