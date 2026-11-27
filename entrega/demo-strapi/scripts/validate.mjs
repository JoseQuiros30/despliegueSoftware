import { readFileSync } from 'node:fs';

const schema = JSON.parse(readFileSync('src/api/articulo/content-types/articulo/schema.json', 'utf8'));
if (schema.info.pluralName !== 'articulos' || !schema.options.draftAndPublish ||
    schema.attributes.categoria.enum.join(',') !== 'noticias,tutoriales,institucional' ||
    !schema.attributes.resumen.required || !schema.attributes.contenido.required) {
  throw new Error('El esquema Artículo difiere del repositorio original');
}
console.log('TypeScript y esquema Artículo original: OK');
