# Deploy and Host Swetrix Analytics with Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/swetrix-analytics-template)

Privacy-first web analytics with funnels, sessions, custom events, and performance tracking — full Swetrix CE on Railway.

**Live demo:** [gateway-production-0764.up.railway.app/login](https://gateway-production-0764.up.railway.app/login)

## What you get

- **Swetrix CE dashboard** — funnels, custom events, sessions, performance
- **Five-service stack** wired on private networking
- **ClickHouse on a volume** — events survive redeploys
- **One public URL** via nginx gateway (this repo)
- **First-user signup** — no shared default admin password

## About Swetrix

[Swetrix](https://swetrix.com/) is open-source, privacy-friendly analytics. The Community Edition tracks page views, custom events, funnels, sessions, and errors. Only a handful of Swetrix templates exist on Railway (~7 listings) compared to thousands for Umami — room to stand out with a complete, documented stack.

## About Hosting Swetrix

This template deploys the official Swetrix v5.4.1 images with Railway Redis, ClickHouse, and an nginx gateway. Only the gateway is public; API, frontend, Redis, and ClickHouse use private DNS.

## Architecture

```
                    ┌─────────────┐
  Browser ──HTTPS──►│   Gateway   │ (this repo)
                    └──────┬──────┘
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌────────────┐  ┌────────────┐  ┌────────────┐
    │ Swetrix FE │  │Swetrix API │  │ ClickHouse │
    │  :8080     │  │   :5005    │  │  (volume)  │
    └────────────┘  └──────┬─────┘  └────────────┘
                           │
                    ┌──────▼──────┐
                    │    Redis    │
                    └─────────────┘
```

## Environment Variables

### Gateway (this repo)

| Variable | Description | Secret | Example/Notes |
| --- | --- | --- | --- |
| `SWETRIX_API_HOST` | Private hostname of Swetrix API | No | `${{Swetrix-API.RAILWAY_PRIVATE_DOMAIN}}` |
| `SWETRIX_FE_HOST` | Private hostname of Swetrix FE | No | `${{Swetrix-FE.RAILWAY_PRIVATE_DOMAIN}}` |
| `SWETRIX_API_PORT` | API port | No | `5005` |
| `SWETRIX_FE_PORT` | FE port (Railway `$PORT`) | No | `8080` |

### Swetrix API (`swetrix/swetrix-api:v5.4.1`)

| Variable | Description | Secret | Example/Notes |
| --- | --- | --- | --- |
| `SECRET_KEY_BASE` | Auth/session secret | Yes | `${{secret(64)}}` |
| `BASE_URL` | Public Swetrix URL | No | `https://${{Gateway.RAILWAY_PUBLIC_DOMAIN}}` |
| `REDIS_HOST` | Redis hostname | No | `redis` (short name — not `.railway.internal`) |
| `REDIS_PORT` | Redis port | No | `6379` |
| `REDIS_PASSWORD` | Redis password | Yes | `${{Redis.REDISPASSWORD}}` |
| `CLICKHOUSE_HOST` | ClickHouse HTTP endpoint | No | `http://${{ClickHouse.RAILWAY_PRIVATE_DOMAIN}}` |
| `CLICKHOUSE_PORT` | ClickHouse HTTP port | No | `8123` |
| `CLICKHOUSE_DATABASE` | ClickHouse database | No | `analytics` |
| `CLICKHOUSE_USER` | ClickHouse user | No | `default` |
| `CLICKHOUSE_PASSWORD` | ClickHouse password | Yes | Same value as ClickHouse service |
| `SMTP_MOCK` | Skip real email (MVP) | No | `true` |
| `DISABLE_REGISTRATION` | Lock registration after first user | No | `true` |
| `CLIENT_IP_HEADER` | Client IP behind proxy | No | `x-forwarded-for` |

### Swetrix FE (`swetrix/swetrix-fe:v5.4.1`)

| Variable | Description | Secret | Example/Notes |
| --- | --- | --- | --- |
| `BASE_URL` | Public Swetrix URL | No | `https://${{Gateway.RAILWAY_PUBLIC_DOMAIN}}` |

### ClickHouse

| Variable | Description | Secret | Example/Notes |
| --- | --- | --- | --- |
| `CLICKHOUSE_DB` | Database name | No | `analytics` |
| `CLICKHOUSE_USER` | User | No | `default` |
| `CLICKHOUSE_PASSWORD` | Password | Yes | `${{secret(32)}}` |

Attach a **volume** at `/var/lib/clickhouse`.

## Deploy and Host

1. Create a new Railway project.
2. Add **Redis** (Database → Redis).
3. Add **ClickHouse** — Docker image `clickhouse/clickhouse-server:25.8-alpine`, volume at `/var/lib/clickhouse`.
4. Add **Swetrix API** — `swetrix/swetrix-api:v5.4.1` with variables above.
5. Add **Swetrix FE** — `swetrix/swetrix-fe:v5.4.1` with `BASE_URL`.
6. Deploy **this repo** as **Gateway** with host/port variables above.
7. Enable **public HTTP** on Gateway only.
8. Open the gateway URL → **register first user** at `/login`.
9. Create a Swetrix project and add the tracking script.

Or run `scripts/deploy-swetrix-railway.ps1` from the monorepo.

## Common Use Cases

- Funnels and custom events without GA4
- Privacy-first analytics for side projects and MVPs
- Session and performance tracking you self-host
- Teams that want Swetrix CE without VPS Docker Compose

## Why not Umami?

Choose **Swetrix** when you need funnels, custom events, or session-level analytics. Choose **Simple Analytics** (same author) when you want a tiny FastAPI app you own outright.

## Troubleshooting

| Issue | Fix |
| --- | --- |
| API cannot connect to Redis | Set `REDIS_HOST=redis` (short name), not `redis.railway.internal` |
| Gateway 502 | Set `SWETRIX_FE_PORT=8080` — Railway overrides FE port from 3000 |
| ClickHouse crash loop | Volume must mount at `/var/lib/clickhouse` (not `/data`). Wipe volume if corrupted from wrong path. |
| Registration closed | Expected after first user when `DISABLE_REGISTRATION=true` |

## Dependencies for Swetrix Hosting

| Service | Source | Volume |
| --- | --- | --- |
| Gateway | GitHub repo (this template) | — |
| Swetrix API | `swetrix/swetrix-api:v5.4.1` | — |
| Swetrix FE | `swetrix/swetrix-fe:v5.4.1` | — |
| Redis | Railway Redis plugin | — |
| ClickHouse | `clickhouse/clickhouse-server:25.8-alpine` | `/var/lib/clickhouse` |

## Deployment Dependencies

- [Swetrix self-hosting guide](https://swetrix.com/docs/selfhosting/how-to)
- [Swetrix configuration](https://swetrix.com/docs/selfhosting/configuring)
- [Swetrix selfhosting repo](https://github.com/Swetrix/selfhosting)

## Why Deploy Swetrix on Railway?

One HTTPS URL, five services on private networking, ClickHouse on a volume — Swetrix CE without maintaining Docker Compose on a VPS. Recommend **2GB+ RAM** for ClickHouse.

## Marketing site

Preview `website/index.html`. Marketplace icon: export `website/icon.svg` to 512×512 PNG.

## Author

romeoxt — herbylegall9@gmail.com

## License

MIT (this template). Swetrix CE is licensed separately.
