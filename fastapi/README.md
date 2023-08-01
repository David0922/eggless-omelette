### dev

```
pip install fastapi "uvicorn[standard]"

uvicorn main:app --host 0.0.0.0 --port 3000 --reload
```

### run locally

```
uvicorn main:app --host 0.0.0.0 --port 3000
```

### build docker image

```
docker build -t fastapi-server .
```

### run docker container

```
docker run --rm -it -p 3000:3000 fastapi-server
```

### verify that it works

```
curl localhost:3000
```
