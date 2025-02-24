helm repo add druid-helm https://asdf2014.github.io/druid-helm/
helm repo update

helm install my-druid druid-helm/druid --namespace druid --create-namespace -f default-values.yaml

helm upgrade my-release oci://registry-1.docker.io/bitnamicharts/clickhouse --namespace clickhouse --create-namespace -f clickhouse-values.yaml

helm uninstall my-druid druid-helm/druid --namespace druid



