docker build -t wol-container -f Dockerfile-wol .

docker tag wol-container huyvu8051/wol-container:latest
docker push huyvu8051/wol-container:latest

docker run --network host wol-container
