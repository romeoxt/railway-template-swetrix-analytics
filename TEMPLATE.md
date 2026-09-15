# Railway Template Composer Setup

## Marketplace listing

- **Title:** Deploy and Host Swetrix Analytics with Railway
- **Short description:** Privacy-first analytics with funnels, sessions, and custom events — full Swetrix CE stack on Railway.
- **Icon:** `website/icon-512.png`
- **Differentiator:** Funnels + custom events; ~7 Swetrix listings vs 4.2K Umami; no default admin password
- **Category:** Analytics
- **Deploy URL:** https://railway.com/deploy/swetrix-analytics-template
- **Overview:** paste `README.md`

## Services

| Service | Source | Volume | Public HTTP |
| --- | --- | --- | --- |
| Gateway | GitHub repo (nginx Dockerfile) | — | Yes |
| Swetrix-API | `swetrix/swetrix-api:v5.4.1` | — | No |
| Swetrix-FE | `swetrix/swetrix-fe:v5.4.1` | — | No |
| Redis | Railway Redis plugin | — | No |
| ClickHouse | `clickhouse/clickhouse-server:25.8-alpine` | `/var/lib/clickhouse` | No |

## Variables — Gateway

| Variable | Value | Secret |
| --- | --- | --- |
| `SWETRIX_API_HOST` | `${{Swetrix-API.RAILWAY_PRIVATE_DOMAIN}}` | No |
| `SWETRIX_FE_HOST` | `${{Swetrix-FE.RAILWAY_PRIVATE_DOMAIN}}` | No |
| `SWETRIX_FE_PORT` | `8080` | No — Railway sets `$PORT` on FE |
| `SWETRIX_API_PORT` | `5005` | No |

## Variables — Swetrix-API

| Variable | Value | Secret |
| --- | --- | --- |
| `SECRET_KEY_BASE` | `${{secret(64)}}` | Yes |
| `BASE_URL` | `https://${{Gateway.RAILWAY_PUBLIC_DOMAIN}}` | No |
| `REDIS_HOST` | `redis` | No |
| `REDIS_PORT` | `6379` | No |
| `REDIS_PASSWORD` | `${{Redis.REDISPASSWORD}}` | Yes |
| `CLICKHOUSE_HOST` | `http://${{ClickHouse.RAILWAY_PRIVATE_DOMAIN}}` | No |
| `CLICKHOUSE_PORT` | `8123` | No |
| `CLICKHOUSE_DATABASE` | `analytics` | No |
| `CLICKHOUSE_USER` | `default` | No |
| `CLICKHOUSE_PASSWORD` | (shared secret) | Yes |
| `SMTP_MOCK` | `true` | No |
| `DISABLE_REGISTRATION` | `true` | No |
| `CLIENT_IP_HEADER` | `x-forwarded-for` | No |

## Variables — Swetrix-FE

| Variable | Value | Secret |
| --- | --- | --- |
| `BASE_URL` | `https://${{Gateway.RAILWAY_PUBLIC_DOMAIN}}` | No |

## Variables — ClickHouse

| Variable | Value | Secret |
| --- | --- | --- |
| `CLICKHOUSE_DB` | `analytics` | No |
| `CLICKHOUSE_USER` | `default` | No |
| `CLICKHOUSE_PASSWORD` | `${{secret(32)}}` | Yes |

## Publish notes

- Only Gateway gets a public domain
- First user registers on first visit; highlight vs Umami default credentials
- Recommend 2GB+ plan for ClickHouse + API
