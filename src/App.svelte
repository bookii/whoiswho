<script lang="ts">
  import { Toaster } from "$lib/components/ui/sonner";
  import DiscordOverlayGenerator from "./lib/DiscordOverlayGenerator.svelte";
</script>

<main class="min-h-screen p-6 bg-background flex flex-col">
  <div class="flex-1">
    <DiscordOverlayGenerator />
  </div>
  <Toaster />
  <footer class="mt-6 text-center text-sm text-muted-foreground">
    &copy; {new Date().getFullYear()} mizznoff (<a
      target="_blank"
      href="https://x.com/mizz_noff">X</a
    >
    / <a target="_blank" href="https://mizznoff.booth.pm">BOOTH</a> /
    <a target="_blank" href="https://github.com/bookii/whoiswho">GitHub</a>)
  </footer>
</main>
