/**
 * Admin Middleware
 * Protects /admin routes — only allows users whose UUID is in the admin list
 */
export default defineNuxtRouteMiddleware((to) => {
  const authStore = useAuthStore();
  const config = useRuntimeConfig();

  const adminUsers = (config.public.adminUsers as string || '')
    .split(',')
    .map(id => id.trim())
    .filter(Boolean);

  const userUUID = authStore.getUserUUID;

  if (!userUUID || !adminUsers.includes(userUUID)) {
    return navigateTo('/');
  }
});
