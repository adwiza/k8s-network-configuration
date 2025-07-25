helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm upgrade --install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
helm upgrade --install istiod istio/istiod -n istio-system --wait
kubectl create namespace istio-ingress
helm upgrade --install istio-ingressgateway istio/gateway -n istio-ingress