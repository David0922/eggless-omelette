```bash
curl --request POST --json '{"username": "pika", "password": "mochi"}' --verbose localhost:3000/api/v1/register
JWT=$(curl --request POST --json '{"username": "pika", "password": "mochi"}' localhost:3000/api/v1/login)
curl --header "Authorization: Bearer $JWT" --verbose localhost:3000/api/v1/protected
```
