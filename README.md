```shell
docker build -t huyvu8051/wol-container:latest -f Dockerfile-wol . 
docker push huyvu8051/wol-container:latest 
docker run --network host huyvu8051/wol-container:latest
```

```shell
docker build -t huyvu8051/tiptalk-build-webapp:latest -f Dockerfile-wol . 
docker push huyvu8051/tiptalk-build-webapp:latest
docker run --network host huyvu8051/tiptalk-build-webapp:latest
```
