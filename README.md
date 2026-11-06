# Deploy OpenSEO on Uniac

Use this repository to create a self-hosted [OpenSEO](https://github.com/every-app/open-seo)
installation on [Uniac](https://uniac.ai). It contains the service composition,
container adapters, and deployment instructions. OpenSEO itself comes from its
official standalone image, pinned by digest in `runtime/Dockerfile`.

To deploy with a coding agent, give it this repository and ask:

> Deploy this repository on Uniac. Follow AGENTS.md and help me through any
> account or provider setup that needs my input.

## What runs

- `runtime/` runs OpenSEO under celld, initializes its database, and starts its
  authenticated crawl gateway. Configuration and runtime state share a durable
  volume. The app runs as the image's unprivileged `node` user.
- `storage/` provides private S3-compatible storage through RustFS and its own
  durable volume.
- `web/` exposes the app through Uniac HTTPS, forwards WebSocket upgrades, and
  blocks the private administrator and import routes.
- `uniac.yaml.example` declares these three services and their storage.

The standalone runtime supplies the Workers APIs used by OpenSEO. This deployment
uses your Uniac account and does not require a Cloudflare account.

## Prepare

Follow [Uniac's agent setup](https://uniac.ai/agents.md) to install its CLI and
skill, and sign in. Keep Docker running. For a Docker context such as Colima,
set `DOCKER_HOST` to the socket reported by `docker context inspect CONTEXT`.

```sh
git clone https://github.com/uniac-dev/open-seo.git
cd open-seo
cp uniac.yaml.example uniac.yaml
chmod 600 uniac.yaml
```

Edit the private `uniac.yaml` before deploying:

- Replace `REPLACE_WITH_RANDOM_STORAGE_SECRET` with a unique random secret.
- Set `DATAFORSEO_API_KEY` to the base64 encoding of your DataForSEO API
  `login:password` to enable SEO data.
- Optionally set `OPENROUTER_API_KEY` for the in-app AI assistant. Google
  integrations use your own OAuth application and client credentials.

The manifest and `.uniac/` are ignored by Git. Image builds include only the
three adapter directories. Uniac stores environment values with the deployment
and shows them in its dashboard. Provider calls are billed by those providers.

## Deploy privately and create the administrator

For a new installation, choose a project name and run:

```sh
uniac plan
uniac project create openseo
uniac link openseo
uniac deploy
uniac logs runtime --tail 100
```

All services start private. Wait for `OpenSEO initialized and ready.` in the
runtime logs, then verify application health and create your account:

```sh
uniac exec runtime -- curl -fsS http://127.0.0.1:8080/api/health
uniac exec -i runtime -- node /opt/standalone/admin.mjs create-user EMAIL NAME
```

The administrator command reads its password from standard input. Supply it from
a private local file or a password manager, rather than as a command argument.
The first account closes public registration, so complete this before exposure.

## Enable public access

In the `web` deployment in `uniac.yaml`, set
`public_ports: [{port: 80, type: http}]`. Run `uniac deploy`, then `uniac status web`
to read the allocated HTTPS address. Set `BETTER_AUTH_URL` to that origin and
deploy again. Verify `/api/health` and sign in at the public address.

An MCP client connects to the same origin at `/mcp` and signs in with the
OpenSEO account. Verify the connection with the free `whoami` and `list_projects`
tools before running research.

## Update an existing installation

Reuse its project binding, private manifest, service names, volume names, storage
credentials, and public origin. Apply configuration changes with `uniac deploy`.
The singleton services stop their old container before starting a replacement;
the data remains on their durable volumes.

Before changing an image digest, back up both volumes while the app is stopped.
Keep `/state/config` with the data: it contains the generated authentication and
operator secrets. Migrations run at startup. Restoring an older image does not
reverse database migrations.

## Upstream and license

OpenSEO application development, provider documentation, and release notes live
in [every-app/open-seo](https://github.com/every-app/open-seo). This deployment
uses its published images and retains the upstream [MIT license](LICENSE).
