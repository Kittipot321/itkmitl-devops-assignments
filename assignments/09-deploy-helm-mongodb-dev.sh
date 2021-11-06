#! /bin/sh

# Create Namespace & set-context to default namespace
gcloud container clusters get-credentials k8s --project zcloud-cicd --zone asia-southeast1-a
kubectl create ns student1-bookinfo-dev
kubectl config set-context $(kubectl config current-context) --namespace=student1-bookinfo-dev

# Create Secret & ConfigMap
kubectl create secret generic registry-bookinfo   --from-file=.dockerconfigjson=$HOME/.docker/config.json   --type=kubernetes.io/dockerconfigjson
kubectl create secret generic bookinfo-dev-ratings-mongodb-secret   --from-literal=mongodb-password=CHANGEME   --from-literal=mongodb-root-password=CHANGEME
kubectl create configmap bookinfo-dev-ratings-mongodb-initdb   --from-file=../bookinfo/ratings/databases/ratings_data.json   --from-file=../bookinfo/ratings/databases/script.sh

# Deploy with Helm
helm install -f ../bookinfo/ratings/k8s/helm-values/values-bookinfo-dev-ratings-mongodb.yaml   bookinfo-dev-ratings-mongodb bitnami/mongodb --version 10.28.4