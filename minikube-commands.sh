minikube start --cpus=15 --memory=7000

minikube dashboard

minikube addons enable metrics-server

minikube service my-druid-broker -n druid   
minikube service my-druid-overlord -n druid   
minikube service my-druid-router -n druid   
