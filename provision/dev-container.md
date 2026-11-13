```bash
# docker build \
#   --no-cache \
#   --progress plain \
#   -t dev_env \
#   https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/Dockerfile.dev

nerdctl build \
  --no-cache \
  --progress plain \
  -t dev_env \
  -f /work-dir/projects/eggless-omelette/provision/Dockerfile.dev \
  .
```

```bash
# docker run --rm -it --name dev_01 \
#   --network host \
#   -v /work-dir/dev_01:/david/projects \
#   dev_env \
#   sudo /usr/sbin/sshd -D -e -p 9022

# init_dev_01() {
#   docker exec dev_01 /bin/bash -c 'mkdir -p /home/david/.ssh'
#   cat ~/.ssh/authorized_keys | docker exec -i dev_01 /bin/bash -c 'cat > /home/david/.ssh/authorized_keys'
#   cat ~/.ssh/config | docker exec -i dev_01 /bin/bash -c 'cat > /home/david/.ssh/config'
#   cat ~/.ssh/github | docker exec -i dev_01 /bin/bash -c 'cat > /home/david/.ssh/github'
#   docker exec dev_01 /bin/bash -c 'chmod 600 /home/david/.ssh/*'
#   docker exec dev_01 /bin/bash -c 'sudo chown david:david /david/projects'
# }
# init_dev_01

# docker exec -it dev_01 /usr/bin/zsh

nerdctl run --rm -it --name dev_01 \
  --network host \
  -v /work-dir/dev_01:/david/projects \
  dev_env

init_dev_01() {
  nerdctl exec dev_01 /bin/bash -c 'mkdir -p /home/david/.ssh'
  cat ~/.ssh/authorized_keys | nerdctl exec -i dev_01 /bin/bash -c 'cat > /home/david/.ssh/authorized_keys'
  cat ~/.ssh/config | nerdctl exec -i dev_01 /bin/bash -c 'cat > /home/david/.ssh/config'
  cat ~/.ssh/github | nerdctl exec -i dev_01 /bin/bash -c 'cat > /home/david/.ssh/github'
  nerdctl exec dev_01 /bin/bash -c 'chmod 600 /home/david/.ssh/*'
  nerdctl exec dev_01 /bin/bash -c 'sudo chown david:david /david/projects'
}
init_dev_01

nerdctl exec -it dev_01 /usr/bin/zsh
```

```bash
nerdctl rm -f dev_01
```
