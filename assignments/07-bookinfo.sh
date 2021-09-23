#! /bin/sh
cd ../../docker-assignment/itkmitl-bookinfo-ratings
docker build -t ratings .
docker run -d --name mongodb -p 27017:27017   -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb   -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings

cd ../itkmitl-bookinfo-details
docker build -t details .
docker run -d -it --name details -p 8081:9080 -e ENABLE_EXTERNAL_BOOK_SERVICE=true details

cd ../itkmitl-bookinfo-reviews
docker build -t reviews .
docker run -d --name reviews --link ratings:ratings -p 8082:9080 -e ENABLE_RATINGS=true -e RATINGS_SERVICE="http://ratings:8080" reviews

cd ../itkmitl-bookinfo-productpage
docker build -t productpage .
docker run -d --name productpage --link ratings:ratings --link details:details --link reviews:reviews -p 8083:9080 -e DETAILS_HOSTNAME="http://details:9080" -e RATINGS_HOSTNAME="http://ratings:8080" -e REVIEWS_HOSTNAME="http://reviews:9080" productpage
