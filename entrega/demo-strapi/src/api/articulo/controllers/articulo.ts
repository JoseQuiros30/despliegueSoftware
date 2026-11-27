import { factories } from '@strapi/strapi';

export default factories.createCoreController('api::articulo.articulo', () => ({
  async find(ctx) {
    ctx.query.status = 'published';
    return super.find(ctx);
  },
  async findOne(ctx) {
    ctx.query.status = 'published';
    return super.findOne(ctx);
  },
}));
