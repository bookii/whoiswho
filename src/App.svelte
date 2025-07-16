<script lang="ts">
  import { Toaster } from "$lib/components/ui/sonner";
  import DiscordOverlayGenerator from "./lib/DiscordOverlayGenerator.svelte";
</script>

<main class="min-h-screen p-6 bg-background">
  <DiscordOverlayGenerator />
  <Toaster />
</main>
