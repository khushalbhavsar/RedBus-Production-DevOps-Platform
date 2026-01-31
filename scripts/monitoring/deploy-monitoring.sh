#!/bin/bash
# Deploy Prometheus and Grafana Monitoring Stack to EKS
# Usage: ./deploy-monitoring.sh

set -e

echo "🚀 Deploying Prometheus & Grafana Monitoring Stack..."

# Apply all monitoring manifests in order
kubectl apply -f infra/kubernetes/monitoring/namespace.yml
kubectl apply -f infra/kubernetes/monitoring/prometheus-rbac.yml
kubectl apply -f infra/kubernetes/monitoring/prometheus-configmap.yml
kubectl apply -f infra/kubernetes/monitoring/prometheus-deployment.yml
kubectl apply -f infra/kubernetes/monitoring/grafana-configmap.yml
kubectl apply -f infra/kubernetes/monitoring/grafana-deployment.yml
kubectl apply -f infra/kubernetes/monitoring/node-exporter.yml
kubectl apply -f infra/kubernetes/monitoring/kube-state-metrics.yml

echo "⏳ Waiting for Node Exporter to be ready..."
kubectl rollout status daemonset/node-exporter -n monitoring --timeout=120s

echo "⏳ Waiting for Kube State Metrics to be ready..."
kubectl rollout status deployment/kube-state-metrics -n monitoring --timeout=120s

echo "⏳ Waiting for Prometheus to be ready..."
kubectl rollout status deployment/prometheus -n monitoring --timeout=120s

echo "⏳ Waiting for Grafana to be ready..."
kubectl rollout status deployment/grafana -n monitoring --timeout=120s

# Restart Prometheus to pick up new config
echo "🔄 Restarting Prometheus to reload configuration..."
kubectl rollout restart deployment/prometheus -n monitoring
kubectl rollout status deployment/prometheus -n monitoring --timeout=120s

echo ""
echo "✅ Monitoring Stack Deployed Successfully!"
echo ""
echo "📊 Access URLs (replace <NODE_IP> with your EKS node IP):"
echo "   Prometheus: http://<NODE_IP>:30090"
echo "   Grafana:    http://<NODE_IP>:30030"
echo ""
echo "🔑 Grafana Credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "📝 To get Node IP:"
echo "   kubectl get nodes -o wide"
echo ""
echo "📝 To verify targets in Prometheus:"
echo "   1. Go to Prometheus UI -> Status -> Targets"
echo "   2. Verify node-exporter and kube-state-metrics are UP"
echo ""
echo "📝 Recommended Dashboards:"
echo "   - 1860: Node Exporter Full (requires node-exporter)"
echo "   - 11074: Node Exporter for Prometheus"
echo "   - 7249: Kubernetes Cluster (requires kube-state-metrics)"
echo ""
echo "📝 To verify services:"
kubectl get pods -n monitoring
kubectl get svc -n monitoring
