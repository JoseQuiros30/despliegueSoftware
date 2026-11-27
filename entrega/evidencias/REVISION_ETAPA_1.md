# Revisión de evidencias locales · 27 de noviembre de 2026

Se inspeccionaron visualmente las capturas entregadas y la base SQLite local.
Los archivos se renombraron para que su nombre corresponda a lo que muestran;
ninguna captura original se borró.

| Archivo | Resultado de la revisión |
|---|---|
| `01-local-admin.png` | Panel de administración visible; válida |
| `01b-local-arranque.png` | Strapi 5.61.0, Node 22 y SQLite iniciados; válida |
| `02-local-articulo.png` | Artículo `Prueba Articulo` publicado; válida |
| `02b-local-publicacion.png` | Confirmación de publicación y campos del modelo; válida |
| `03-local-api.png` | API pública devuelve el artículo publicado y `total: 1`; válida |
| `03b-local-health.png` | Health `status: ok`; el listado aparece vacío porque la captura precede a la publicación |

La base `demo-strapi/.tmp/data.db` contiene una versión publicada del artículo
`Prueba Articulo`. Se consultó la API local en vivo y respondió HTTP 200 con
ese artículo y `total: 1`; la implementación funciona. La etapa local queda
documentada con estas seis capturas y `VALIDACIONES_LOCALES.md`; las versiones,
`lint`, `test` y `build` no requieren capturas repetidas. No se observaron
secretos en las capturas inspeccionadas.
