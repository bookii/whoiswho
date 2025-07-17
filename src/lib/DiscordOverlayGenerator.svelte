<script lang="ts">
  import { Badge } from "$lib/components/ui/badge";
  import * as Card from "$lib/components/ui/card";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";
  import * as RadioGroup from "$lib/components/ui/radio-group";
  import { Toggle } from "$lib/components/ui/toggle";
  import { Copy, PenLine, Plus, Trash2, Volume2, VolumeX } from "lucide-svelte";
  import outdent from "outdent";
  import { toast } from "svelte-sonner";
  import ColorPicker from "./components/ColorPicker.svelte";
  import DiscordIdHelpDialog from "./components/DiscordIdHelpDialog.svelte";
  import DiscordUserListItem from "./components/DiscordUserListItem.svelte";
  import Button from "./components/ui/button/button.svelte";

  type UserData = {
    id: string;
    discordId: string;
    colorHex: string;
    characterName: string;
  };

  let users = $state<UserData[]>([]);
  const defaultColorHex = "#FE0016";
  let colorMode = $state<"colored" | "uncolored">("colored");
  let isSpeaking = $state(true);
  const initialFormData = {
    discordId: "",
    colorHex: defaultColorHex,
    characterName: "",
  };
  let formData = $state(initialFormData);
  let editingUserIds = $state<string[]>([]);
  let editDataRecord = $state<Record<string, UserData>>({});

  const isValidateDiscordId = (id: string) => {
    return id.trim() !== "" && /^\d{17,18}$/.test(id);
  };
  const discordIdErrorMessage = "Discord ID は 17~18 桁の数字です";

  const styleElement = document.createElement("style");

  const onSubmit = (
    event: SubmitEvent & { currentTarget: EventTarget & HTMLFormElement }
  ) => {
    event.preventDefault();

    if (!isValidateDiscordId(formData.discordId)) {
      toast.error(discordIdErrorMessage);
      return;
    }

    users = [...users, { id: Date.now().toString(), ...formData }];
    formData = initialFormData;

    toast.success("ユーザーを追加しました");
  };

  const onDelete = (id: string) => {
    users = users.filter((user) => user.id !== id);
    delete editDataRecord[id];
    toast.success("ユーザーを削除しました");
  };

  const onToggleColor = () => {
    if (colorMode === "colored") {
      users = users.map((user) => ({
        ...user,
        colorHex: user.colorHex || defaultColorHex,
      }));
    }
  };

  const onStartEdit = (user: UserData) => {
    editingUserIds = [...editingUserIds, user.id];
    editDataRecord[user.id] = { ...user };
  };

  const onCancelEdit = (id: string) => {
    editingUserIds = editingUserIds.filter((userId) => userId !== id);
    delete editDataRecord[id];
  };

  const onSaveEdit = (id: string) => {
    const editedUser = editDataRecord[id];
    if (!isValidateDiscordId(editedUser.discordId)) {
      toast.error(discordIdErrorMessage);
      return;
    }

    users = users.map((user) =>
      user.id === id ? { ...user, ...editedUser } : user
    );
    editingUserIds = editingUserIds.filter((userId) => userId !== id);
    delete editDataRecord[id];

    toast.success("ユーザー情報を更新しました");
  };

  const generateCSS = ({
    targetUsers,
    isPreview,
  }: {
    targetUsers: Omit<UserData, "id">[];
    isPreview: boolean;
  }) => {
    let css = "";

    if (!isPreview) {
      css += outdent`
        body {
          background-color: rgba(0, 0, 0, 0);
          margin: 0px auto;
          overflow: hidden;
        }
      `;
      css += "\n\n";
    }

    css += outdent`
      .voice_state {
        display: flex;
        align-items: center;
        padding-top: ${colorMode === "colored" ? "10px" : "8px"};
        padding-bottom: ${colorMode === "colored" ? "10px" : "8px"};
        padding-left: 8px;
      }

      .voice_avatar {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        margin-right: ${colorMode === "colored" ? "10px" : "6px"};
        border: 5px solid transparent;
        filter: brightness(80%);
        transition: filter 0.1s ease;
        ${colorMode === "colored" ? "padding: 4px !important;" : ""}
      }

      .wrapper_speaking .voice_avatar {
        filter: none;
        transition: filter 0.1s ease;
      }

      .voice_username {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 4px;
        padding-top: 0px; /* overwrite */
      }

      .voice_username span {
        display: flex;
        align-items: center;
        font-size: 18px !important;
        font-weight: bold;
        padding-left: 6px !important;
        padding-right: 6px !important;
        border-radius: 3px !important;
        height: 28px;
        color: white;
        background-color: rgba(30, 33, 36, 0.95);
      }

      .voice_username::after {
        display: flex;
        align-items: center;
        font-size: 14px;
        font-weight: bold;
        padding-left: 6px;
        padding-right: 6px;
        border-radius: 3px;
        height: 22px;
        color: white;
        background-color: rgba(90, 99, 108, 0.95);
      }
    `;

    for (const user of targetUsers) {
      if (colorMode === "colored" && user.colorHex) {
        css += "\n\n";
        css += outdent`
          [data-userid="${user.discordId}"] .voice_avatar {
            border-color: ${user.colorHex};
          }
        `;
      }
      if (user.characterName.trim()) {
        css += "\n\n";
        css += outdent`
          [data-userid="${user.discordId}"] .voice_username::after {
            content: "${user.characterName}";
          }
        `;
      }
    }

    console.log("Generated CSS: \n", css);

    return css;
  };

  const copyCSS = () => {
    const css = generateCSS({ targetUsers: users, isPreview: false });
    navigator.clipboard
      .writeText(css)
      .then(() => {
        toast.success("CSS をクリップボードにコピーしました");
      })
      .catch(() => {
        toast.error("CSS のコピーに失敗しました");
      });
  };

  const getPreviewUsers = () => {
    const currentUsers = users.map((user) => {
      return editDataRecord[user.id] ?? user;
    });
    return [...currentUsers, formData];
  };

  $effect(() => {
    document.head.appendChild(styleElement);
    styleElement.textContent = generateCSS({
      targetUsers: getPreviewUsers(),
      isPreview: true,
    });
    return () => {
      document.head.removeChild(styleElement);
    };
  });
</script>

<div class="w-full max-w-6xl mx-auto space-y-6">
  <Card.Root>
    <Card.Header>
      <Card.Title class="text-2xl">
        コラボ配信の操作キャラ表示ジェネレーター
      </Card.Title>
      <Card.Description style="font-size: 1rem;">
        <a target="_blank" href="https://streamkit.discord.com/overlay"
          >Discord Streamkit Overlay</a
        >の通話中ユーザーのアイコンを色分けしたり、操作キャラ名を表示したりできるCSSジェネレーター
      </Card.Description>
    </Card.Header>
    <Card.Content>
      <div class="mb-6 p-4 bg-secondary/50 rounded-lg">
        <RadioGroup.Root bind:value={colorMode} class="flex flex-wrap gap-4">
          <div class="flex items-center gap-2">
            <RadioGroup.Item
              name="color"
              id="colored"
              value="colored"
              onchange={onToggleColor}
              class="text-primary bg-white"
            />
            <Label for="colored">外枠を表示する</Label>
          </div>
          <div class="flex items-center gap-2">
            <RadioGroup.Item
              name="color"
              id="uncolored"
              value="uncolored"
              onchange={onToggleColor}
              class="text-primary bg-white"
            />
            <Label for="uncolored">外枠を表示しない</Label>
          </div>
        </RadioGroup.Root>
      </div>
      <form
        onsubmit={onSubmit}
        class="grid gap-4 grid-cols-1 {colorMode === 'colored'
          ? 'md:grid-cols-4'
          : 'md:grid-cols-3'}"
      >
        <div class="space-y-2">
          <div class="flex items-center gap-1 h-4">
            <Label for="discordId">Discord ID</Label>
            <Badge variant="outline">必須</Badge>
            <DiscordIdHelpDialog />
          </div>
          <Input
            id="discordId"
            type="text"
            bind:value={formData.discordId}
            placeholder="例: 123456789012345678"
            onchange={(event) => {
              if (event.target instanceof HTMLInputElement) {
                formData.discordId = event.target.value;
              }
            }}
            required
          />
          {#if formData.discordId && !isValidateDiscordId(formData.discordId)}
            <p class="text-xs text-destructive">{discordIdErrorMessage}</p>
          {/if}
        </div>
        {#if colorMode === "colored"}
          <div class="space-y-2">
            <Label for="colorHex" class="h-4">外枠の色</Label>
            <ColorPicker
              colorHex={formData.colorHex}
              onChange={(colorHex) => {
                formData.colorHex = colorHex;
              }}
            />
          </div>
        {/if}
        <div class="space-y-2">
          <Label for="discordId" class="h-4">操作キャラ名</Label>
          <Input
            id="characterName"
            type="text"
            bind:value={formData.characterName}
            placeholder="例: マリオ"
            onchange={(event) => {
              if (event.target instanceof HTMLInputElement) {
                formData.characterName = event.target.value;
              }
            }}
          />
        </div>
        <div class="space-y-2">
          <Label class="h-4" />
          <Button
            type="submit"
            class="w-full"
            disabled={!isValidateDiscordId(formData.discordId)}
          >
            <Plus class="size-4" />
            追加
          </Button>
        </div>
      </form>
      <div class="mt-6 p-4 bg-secondary/50 rounded-lg">
        <div class="flex items-cente space-x-2 mb-2">
          <Label>プレビュー</Label>
          <Toggle
            variant="outline"
            pressed={isSpeaking}
            onPressedChange={() => {
              isSpeaking = !isSpeaking;
            }}
            class="!bg-white !text-secondary-foreground hover:!bg-secondary/50"
          >
            {#if isSpeaking}
              <Volume2 class="size-4" />発話あり
            {:else}
              <VolumeX class="size-4" />発話なし
            {/if}
          </Toggle>
        </div>

        <div class="voice_container">
          <ul>
            <DiscordUserListItem
              userNumber={users.length + 1}
              discordId={formData.discordId}
              {isSpeaking}
            />
          </ul>
        </div>
      </div>
    </Card.Content>
  </Card.Root>

  {#if users.length > 0}
    <Card.Root>
      <Card.Header>
        <div class="flex items-center space-x-3">
          <Card.Title class="text-xl"
            >登録済みユーザー ({users.length})</Card.Title
          >
          <Toggle
            variant="outline"
            pressed={isSpeaking}
            onPressedChange={() => {
              isSpeaking = !isSpeaking;
            }}
            class="!bg-white !text-secondary-foreground hover:!bg-secondary/50"
          >
            {#if isSpeaking}
              <Volume2 class="size-4" />発話あり
            {:else}
              <VolumeX class="size-4" />発話なし
            {/if}
          </Toggle>
        </div>
      </Card.Header>
      <Card.Content>
        <ul class="bg-secondary/50 rounded-lg p-4">
          {#each users as user, index}
            <div class="flex flex-wrap items-center justify-between w-full">
              {#if editingUserIds.includes(user.id)}
                <DiscordUserListItem
                  userNumber={index + 1}
                  discordId={editDataRecord[user.id].discordId}
                  {isSpeaking}
                />
                <div class="flex flex-wrap items-center gap-4 w-full mb-4">
                  <div class="flex-1">
                    <Label for="editDiscordId-{user.id}" class="sr-only">
                      Discord ID
                    </Label>
                    <Input
                      id="editDiscordId-{user.id}"
                      bind:value={editDataRecord[user.id].discordId}
                      onchange={(event) => {
                        if (event.target instanceof HTMLInputElement) {
                          editDataRecord[user.id].discordId =
                            event.target.value;
                        }
                      }}
                      placeholder="Discord ID"
                      class="text-sm min-w-32"
                    />
                  </div>
                  <div class="flex-1">
                    <Label for="editColorHex-{user.id}" class="sr-only">
                      外枠の色
                    </Label>
                    <ColorPicker
                      colorHex={editDataRecord[user.id].colorHex}
                      onChange={(colorHex) => {
                        editDataRecord[user.id].colorHex = colorHex;
                      }}
                    />
                  </div>
                  <div class="flex-1">
                    <Label for="editCharacterName-{user.id}" class="sr-only">
                      操作キャラ名
                    </Label>
                    <Input
                      id="editCharacterName-{user.id}"
                      bind:value={editDataRecord[user.id].characterName}
                      onchange={(event) => {
                        if (event.target instanceof HTMLInputElement) {
                          editDataRecord[user.id].characterName =
                            event.target.value;
                        }
                      }}
                      placeholder="操作キャラ名"
                      class="text-sm min-w-32"
                    />
                  </div>
                  <div class="flex flex-1 space-x-2">
                    <Button
                      size="sm"
                      class="flex-1"
                      onclick={() => {
                        onSaveEdit(user.id);
                      }}
                    >
                      保存
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      class="flex-1"
                      onclick={() => {
                        onCancelEdit(user.id);
                      }}
                    >
                      キャンセル
                    </Button>
                  </div>
                </div>
              {:else}
                <DiscordUserListItem
                  userNumber={index + 1}
                  discordId={user.discordId}
                  {isSpeaking}
                />
                <Card.Root>
                  <Card.Content class="flex flex-wrap space-x-4">
                    <div class="flex items-center space-x-2 text-sm">
                      <span class="font-medium">ID:</span>
                      <span class="text-muted-foreground w-42 truncate">
                        {user.discordId}
                      </span>
                    </div>
                    {#if colorMode === "colored"}
                      <div class="flex items-center space-x-2 text-sm">
                        <span class="font-medium">色:</span>
                        <div class="flex items-center space-x-1">
                          <span
                            class="inline-block size-3 rounded-full border border-gray-300"
                            style="background-color: {user.colorHex};"
                          ></span>
                          <span class="text-muted-foreground w-16">
                            {user.colorHex}
                          </span>
                        </div>
                      </div>
                    {/if}
                    <div class="flex gap-1">
                      <Button
                        variant="ghost"
                        size="sm"
                        onclick={() => onStartEdit(user)}
                        class="size-8"
                      >
                        <PenLine class="size-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onclick={() => onDelete(user.id)}
                        class="size-8 text-destructive hover:text-destructive"
                      >
                        <Trash2 class="size-4" />
                      </Button>
                    </div>
                  </Card.Content>
                </Card.Root>
              {/if}
            </div>
          {/each}
        </ul>
      </Card.Content>
    </Card.Root>
    <Card.Root>
      <Card.Header>
        <div class="flex items-center space-x-3">
          <Card.Title class="text-xl">生成されたCSS</Card.Title>
          <Button
            variant="outline"
            onclick={copyCSS}
            class="flex items-center gap-2"
          >
            <Copy class="size-4" />
            コピー
          </Button>
        </div>
      </Card.Header>
      <Card.Content>
        <pre
          class="mb-6 p-4 text-sm bg-secondary/50 rounded-lg overflow-x-auto whitespace-pre-wrap"><code
            >{generateCSS({ targetUsers: users, isPreview: false })}</code
          ></pre>
      </Card.Content>
    </Card.Root>
  {/if}
</div>
