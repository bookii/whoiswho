<script lang="ts">
  import * as Dialog from "$lib/components/ui/dialog";
  import { HelpCircle } from "lucide-svelte";
</script>

<Dialog.Root>
  <Dialog.Trigger type="button">
    <HelpCircle class="size-4" />
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Header>
      <Dialog.Title>Discord IDの取得方法</Dialog.Title>
      <Dialog.Description>
        <div class="space-y-2 mt-2">
          <p class="text-sm text-muted-foreground leading-normal">
            1.
            Discordのデスクトップアプリの「ユーザー設定」→「詳細設定」を開き、「開発者モード」をオンにします。
          </p>
          <p class="text-sm text-muted-foreground leading-normal">
            2.
            対象のユーザーを右クリックし、「ユーザーIDをコピー」を選択します。
          </p>
          <div class="p-3 bg-secondary/50 rounded-lg">
            <p class="text-sm text-muted-foreground leading-normal">
              詳しくは<a
                class="text-primary"
                target="_blank"
                href="https://support.discord.com/hc/ja/articles/206346498"
                >Discord公式の解説記事</a
              >をご覧ください。
            </p>
          </div>
        </div>
      </Dialog.Description>
    </Dialog.Header>
  </Dialog.Content>
</Dialog.Root>
