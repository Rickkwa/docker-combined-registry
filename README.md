# Docker Combined Registry

[![Build Status](https://travis-ci.com/Rickkwa/docker-combined-registry.svg?branch=master)](https://travis-ci.com/Rickkwa/docker-combined-registry)
[![license](https://img.shields.io/github/license/Rickkwa/docker-combined-registry.svg)](https://github.com/Rickkwa/docker-combined-registry/blob/master/LICENSE)

A single entrypoint to route Docker registry requests between a pull-through cache registry, and a private hosted registry.

## Description

Suppose you have a private hosted Docker registry, and your company policy is to only use images from your own registry. Then to use an image from Docker Hub, you'd need to retag it and push it into your registry. The Docker registry has native functionality to act as a pull-through cache for Docker Hub, but it has the limitation of not allowing for custom images at the same time.

This project uses Nginx with Lua to route requests between both a Docker proxy registry (pull-through cache), and a private registry. That way, you do not need to pull, retag, and push. Instead, all of this is abstracted, and you get a single entrypoint for your two registries.

## Usage

The router image expects three environment variables to be provided:

|Variable|Description|
|--------|-----------|
|AGGREGATE_HOSTNAME|The domain name of the single entrypoint.|
|HOSTED_HOSTNAME|The domain name of the hosted registry to route to.|
|PROXY_HOSTNAME|The domain name of the proxy registry to route to.|

```bash
# Bring up the registries and router
docker-compose up -d

# Pull an official image from Docker Hub. This request gets routed to the proxy registry.
docker pull registry.localhost/library/nginx:latest

# Push a custom image. This request gets routed to the hosted registry.
docker push registry.localhost/mycustomproject/mycustomimage:latest

# Pull a custom image. This request gets routed to the hosted registry.
docker pull registry.localhost/mycustomproject/mycustomimage:latest
```

## Route Handling

The following shows how the project routes requests to the Docker registry API. See the official API routes [here](https://docs.docker.com/registry/spec/api/#detail).

|Method|Path|Entity|Route Logic|
|------|----|------|-----------|
|GET|`/v2/`|Base|Returns 200 if both the proxy and the hosted registry returns 200 at `/v2/`.|
|GET|`/v2/<name>/tags/list`|Tags|Routes straight to hosted registry.|
|GET|`/v2/<name>/manifests/<reference>`|Manifest|Checks if the resource is available in the proxy first, else routes to hosted.|
|PUT|`/v2/<name>/manifests/<reference>`|Manifest|Routes straight to hosted.|
|DELETE|`/v2/<name>/manifests/<reference>`|Manifest|Routes straight to hosted.|
|GET|`/v2/<name>/blobs/<digest>`|Blob|Checks if the resource is available in the proxy first, else routes to hosted.|
|DELETE|`/v2/<name>/blobs/<digest>`|Blob|Routes straight to hosted.|
|POST|`/v2/<name>/blobs/uploads/`|Initiate Blob Upload|Routes straight to hosted.|
|GET|`/v2/<name>/blobs/uploads/<uuid>`|Blob Upload|Routes straight to hosted.|
|PATCH|`/v2/<name>/blobs/uploads/<uuid>`|Blob Upload|Routes straight to hosted.|
|PUT|`/v2/<name>/blobs/uploads/<uuid>`|Blob Upload|Routes straight to hosted.|
|DELETE|`/v2/<name>/blobs/uploads/<uuid>`|Blob Upload|Routes straight to hosted.|
|GET|`/v2/_catalog`|Catalog|Routes straight to hosted.|

## Monitoring

The router comes with 2 monitoring endpoints:

|Endpoint|Description|
|--------|-----------|
|`/healthcheck`|Returns JSON containing the status code of hitting the `/v2/` endpoint of both the proxy and hosted registries.|
|`/metrics`|Returns usage metrics in Prometheus format.|

## License

MIT. See [LICENSE](LICENSE) for more detail.
