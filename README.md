# Puppet on Azure AKS nodes

This is a workaround as the Azure AKS currently does not support custom scripts on creation of nodes when deploying or scaling AKS.
The repository contains a helm chart for deploying this on the cluster, the container that runs the integration and a Docker in Docker container that runs Ubuntu and is used for local testing of the solution.

The helm chart sets up a daemonset to make sure this is run on each and every node on creation or restart. To manage security and decrease the change of someone breaking in to the cluster or the nodes the "dangerous" parts that needs access to the node runs in an initContainer afterwards a busybox container is run tailing the puppet logs.

It should be idempotent and not destroy the nodes. FYI I take no responsibility if a node gets broken or your house burns down. This is on you! But please create a PR or issue if you come across something to be improved.