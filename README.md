# shop-ops-lab

A small synthetic online shop used for operations exercises: a Postgres
database (`shop-db`) and a product catalog API (`catalog-api`).

Last reviewed: October 2026

## Services

| Service | Container | Port | Notes |
|---|---|---|---|
| Postgres 16 | shop-db | 5440 | database `shop_db`, data in volume `shop_pgdata` |
| Catalog API | catalog-api | 8080 | started only with `--profile api` |

## Database logins

| Login | Password | Purpose |
|---|---|---|
| postgres | postgres | admin |
| app_user | app_pw | the shop application |
| reporting_user | report_pw | analytics dashboards |

All data is synthetic.
