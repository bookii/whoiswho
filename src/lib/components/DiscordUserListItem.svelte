<script lang="ts">
  type Props = {
    userNumber: number;
    discordId: string;
    isSpeaking: boolean;
  };
  const { userNumber, discordId, isSpeaking }: Props = $props();
</script>

<li
  class="voice_state {isSpeaking ? 'wrapper_speaking' : ''}"
  data-userid={discordId}
>
  <div class="voice_avatar">
    <div
      class="w-full h-full bg-gray-500 rounded-full flex items-center justify-center text-white font-bold text-lg"
    >
      USER
    </div>
  </div>
  <div class="voice_username">
    <span>ユーザー{userNumber}</span>
  </div>
</li>
