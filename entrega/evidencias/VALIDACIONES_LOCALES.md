# Validaciones locales reales · 26 de noviembre de 2026

La aplicación se basó en `cms-strapi-gcp` (commit `a9b7e50`). El esquema
`Artículo` de la entrega es idéntico al original y `git status --porcelain`
del repositorio fuente quedó vacío.

| Comprobación | Resultado observado |
|---|---|
| Node.js 22.21.1, `npm ci` | 1447 paquetes instalados desde el lockfile original |
| `npm run lint` | TypeScript compiló sin errores; campos y categorías originales verificados |
| `npm test` | 1/1 prueba aprobada con SQLite temporal, publicación y borrador |
| HTTP desde la prueba | Health 200; listado y detalle publicados 200 aun con `status=draft`; `POST` anónimo 403 |
| `npm run build` | TypeScript y panel de administración compilados |
| `npm run start`, `npm run smoke` | Strapi 5.61.0 inició; `/api/health` 200 con `status: ok` |
| `GET /admin`, `GET /api/articulos` | HTTP 200 en el servidor local |
| Cloud Build | YAML parseado; seis scripts Bash válidos |
| Guía interactiva | JavaScript sin errores de sintaxis |
| `terraform fmt -check -recursive` | Correcto en bootstrap e infra |
| `terraform validate` | Correcto en bootstrap e infra; infra usa proveedor Google 7.46.2 para opciones del montaje GCS |

La construcción de la imagen Docker, Cloud SQL, Cloud Storage FUSE, los triggers
y los dashboards requieren verificación posterior en GCP. Docker no está
instalado localmente. No se ejecutaron `terraform plan` con credenciales,
`apply`, `destroy` ni builds en GCP; no se crearon recursos facturables.

Las carpetas generadas (`node_modules`, `.terraform`, `dist`, `build`, `.tmp`)
y el `.env` local se eliminaron de la entrega tras las validaciones. Las
capturas de nube están pendientes de ejecución real y no se simularon.
