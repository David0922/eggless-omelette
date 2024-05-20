get the right PUID & PGID for `docker-compose.yml`

```bash
id $USER
```

download `.config/peer<id>/peer<id>.conf` to client

show qr code for mobile client

```bash
docker exec -it wireguard /app/show-peer 1
```

#### client

```bash
sudo apt install resolvconf wireguard

# connect to VPN
wg-quick up ./peer1.conf

# check status
sudo wg

# check public ip
curl https://ipinfo.io/ip

# disconnect from VPN
wg-quick down ./peer1.conf
```
