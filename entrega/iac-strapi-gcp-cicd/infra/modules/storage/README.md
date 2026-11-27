# Almacenamiento de archivos del CMS

El módulo crea un bucket privado de Cloud Storage para `public/uploads`, da a
la cuenta de Cloud Run `roles/storage.objectUser` y evita el borrado automático
de archivos (`force_destroy = false`). Cloud Run lo monta con Cloud Storage FUSE
en `/opt/app/public/uploads` como UID/GID 1000, correspondientes a `node`.

Cloud Storage FUSE no ofrece todas las garantías POSIX. La carga, lectura y
eliminación de un archivo se deben comprobar en el paso de validación de GCP.
Consultar [la documentación de montajes de Cloud Run](https://docs.cloud.google.com/run/docs/configuring/services/cloud-storage-volume-mounts).
