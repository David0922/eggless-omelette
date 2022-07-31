microk8s enable registry

./push-img.sh

kubectl apply -f ./curl-me.yaml
kubectl replace -f ./curl-me.yaml
