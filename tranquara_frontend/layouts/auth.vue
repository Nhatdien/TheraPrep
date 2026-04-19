<template>
  <div class="min-h-screen flex items-center justify-center bg-default px-4 pt-[max(1rem,env(safe-area-inset-top))] pb-[max(1rem,env(safe-area-inset-bottom))]">
    <div class="w-full max-w-md flex flex-col">
      <!-- Brand mark -->
      <div class="flex flex-col items-center mb-8 gap-3">
        <BrandLogoMark :size="64" color="#F59E0B" variant="mark" />
        <span class="text-xl font-bold tracking-widest text-highlighted uppercase" style="letter-spacing:0.18em;">
          Theraprep
        </span>
        <p class="text-sm text-muted">Your mental wellness companion</p>
      </div>

      <!-- Page Content (login/register forms) -->
      <div class="shrink-0">
        <slot />
      </div>

      <!-- Terms & Privacy -->
      <div class="text-center mt-6 text-xs text-muted">
        By continuing, you agree to our
        <NuxtLink to="/terms" class="underline hover:text-default">Terms</NuxtLink>
        and
        <NuxtLink to="/privacy" class="underline hover:text-default">Privacy Policy</NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Auth layout — provides branding for login/register pages
</script>
