# Puppet on Azure AKS nodes

This is a workaround as the Azure AKS currently does not support custom scripts on creation of nodes when deploying or scaling AKS.
The repository contains a helm chart for deploying this on the cluster, the container that runs the integration and a Docker in Docker container that runs Ubuntu and is used for local testing of the solution.

The helm chart sets up a daemonset to make sure this is run on each and every node on creation or restart. To manage security and decrease the change of someone breaking in to the cluster or the nodes the "dangerous" parts that needs access to the node runs in an initContainer afterwards a busybox container is run tailing the puppet logs.

It should be idempotent and not destroy the nodes. FYI I take no responsibility if a node gets broken or your house burns down. This is on you! But please create a PR or issue if you come across something to be improved.

## How to build, use and test

### Build ubuntu-dind

This repository is comprised of two docker images; the aks-node-puppet image in its respective directory and the ubuntu-dind image used for testing the aks-node-puppet image.

To test the images you have to copy the aks-node-puppet/template.env file to aks-node-puppet/.env, fill it out and then build the ubuntu-dind image. Do so by running the following command from this repository root.
```
docker build -t ubuntu-dind -f ubuntu-dind/Dockerfile .
```

This will build the image and you are ready for running and testing the image.

### Run ubuntu-dind

Next step is running the ubuntu-dind image and looking for errors. Do that with the following command.
```
docker run -it --privileged ubuntu-dind
```

If all went well you can build, tag and upload the aks-node-puppet image

### Build and upload aks-node-puppet

The image is built much the same way the ubuntu-dind image is built, the only thing you have to think about is tagging and where on docker hub you want to put the image. Go inside the aks-node-puppet folder and build the image with the following command.
```
docker build -t aks-node-puppet:<tag> .
```

Next tag the image for docker hub with the following command.
```
docker tag aks-node-puppet:<tag> <docker hub repo/username>/aks-node-puppet:<tag>
```

And push the image to docker hub
```
docker push <docker hub repo/username>/aks-node-puppet:<tag>
```