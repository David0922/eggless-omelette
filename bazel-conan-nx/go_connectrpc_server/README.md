```bash
curl --header "Content-Type: application/json" --data '
{
  "a": 1,
  "b": 2
}
' localhost:3000/Calculator/Add

grpcurl -protoset <(buf build ./protos/calculator.proto -o -) -plaintext -d '
{
  "a": 1,
  "b": 2
}
' localhost:3000 Calculator/Add
```
