# Deploy OpenSEO on Uniac

This repository creates the services for OpenSEO on Uniac from published images.
Read `README.md`, `uniac.yaml.example`, and https://uniac.ai/agents.md before
deploying. Reuse the user's existing Uniac installation and sign-in when available.

- Generate the root `uniac.yaml` from the example. It is private, ignored by Git,
  and excluded from image builds. Keep credentials out of tracked files and logs.
- Confirm the intended platform and project before every remote change. Reuse
  an existing binding when updating an installation.
- Preserve service names, volume names, and the authentication origin on updates.
- Bootstrap the administrator while all services are private, then enable the web
  endpoint and set its HTTPS origin as described in the README.
- Use the administrator command with its password on standard input. Store a
  generated password in a private local file and tell the user where to find it.
- Verify application health, sign-in, and MCP account/project reads. Provider
  research and scheduled tracking require a separate user request.
- Report the public URL, credential location, verification results, and any
  provider configuration that remains for the user. Keep generated configuration
  outside version control.

The application is maintained at https://github.com/every-app/open-seo. Keep this
repository focused on the Uniac composition and its container adapters.
