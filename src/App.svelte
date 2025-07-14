<script lang="ts">
  import UserStyleForm from "./lib/UserStyleForm.svelte";
</script>

<main>
  <h1>Discord StreamKit Overlay Styler</h1>
  <p class="description">
    Generate CSS styles for Discord StreamKit Overlay to use in OBS Studio. Add
    custom colors and labels to identify users in your stream.
  </p>

  <UserStyleForm />

  <footer>
    <p>
      Built with <a href="https://svelte.dev" target="_blank" rel="noreferrer"
        >Svelte</a
      >
      and
      <a href="https://vite.dev" target="_blank" rel="noreferrer">Vite</a>
    </p>
  </footer>
</main>

<style>
  main {
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
  }

  h1 {
    text-align: center;
    margin-bottom: 0.5em;
  }

  .description {
    text-align: center;
    color: #888;
    margin-bottom: 2em;
  }

  footer {
    margin-top: 3rem;
    text-align: center;
    font-size: 0.8em;
    color: #888;
  }
</style>
