# budget-infra

the infrastructure repo for the budget app

basically as I'm building out each of the other services, I want this to be the repository that holds the shared infrastructure needs for each of the services that I'll be creating. this includes things like the database (postgres), api gateway (traefik), and definitions for each of the services.

### pgadmin

well this was annoying to figure out, but when you connect to the pg database you want to use `host.docker.internal` as the hostname

### traefik

there are some things to clean up with this configuration if I were to deploy this to a production environment, but we're not quite there yet

notably:

- `api.insecure=true` -> `api.insecure=false`
- **do not expose the Traefik dashboard** to the public internet without authentication
- ensure that `TRAEFIK_DASHBOARD_PORT` is **not mapped publicly** or is protected behind a VPN or reverse proxy
