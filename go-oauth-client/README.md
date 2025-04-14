```bash
export $(xargs < .env) && go run .
```

#### self-signed SSL certificate

```bash
openssl req -batch -days 365 -newkey rsa:2048 -noenc -x509 -keyout ./localhost.key -out ./localhost.crt
```

```bash
# mac
open -a 'Google Chrome' -n --args --incognito --new-window --ignore-certificate-errors
```

#### todo

call TradeStation to update callback URI
