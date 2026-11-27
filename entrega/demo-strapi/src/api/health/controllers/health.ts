import type { Core } from '@strapi/strapi';

type HealthContext = { status?: number; body?: { status: string; revision?: string } };

export default ({ strapi }: { strapi: Core.Strapi }) => ({
  async index(ctx: HealthContext) {
    try {
      await strapi.db.connection.raw('SELECT 1');
      ctx.body = { status: 'ok', revision: process.env.APP_REVISION || 'local' };
    } catch (error) {
      strapi.log.error('Health check: database unavailable', error);
      ctx.status = 503;
      ctx.body = { status: 'unavailable' };
    }
  },
});
