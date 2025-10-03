# Config
$CLUSTER_ZONE = "us-central1-a"
$CLUSTER_NAME = "test-cluster"
$APP_LABEL = "app=spot-app"

# Authenticate
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$CLUSTER_ZONE

# Get all On-Demand nodes (those without spot label)
$ondemandNodes = kubectl get nodes -l '!cloud.google.com/gke-spot' -o jsonpath='{.items[*].metadata.name}'

foreach ($node in $ondemandNodes -split " ") {
    if ($node -ne "") {
        Write-Host "Draining node $node..."
        kubectl drain $node --pod-selector=$APP_LABEL --ignore-daemonsets --force --delete-emptydir-data
        Write-Host "Uncordoning node $node..."
        kubectl uncordon $node
    }
}
