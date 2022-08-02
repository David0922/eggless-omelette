### build locally

```
./gradlew build
```

### clean

```
./gradlew clean
```

### run locally

```
java -jar ./build/libs/goodbyeworld-0.0.1.jar
```

### build docker image

```
docker build -t springboot-server .
```

### run docker container

```
docker run --rm -it -p 3000:3000 springboot-server
```

### verify that it works

```
curl localhost:3000
```
