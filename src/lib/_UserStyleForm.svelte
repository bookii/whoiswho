<script lang="ts">
  // ユーザースタイルを管理するための型定義
  type UserStyle = {
    id: string;
    userId: string;
    borderColor: string;
    label: string;
  };

  // 全体設定の型定義
  type GlobalSettings = "border" | "label" | "both";

  // ユーザースタイルの配列（複数登録可能）
  let userStyles: UserStyle[] = $state([
    {
      id: crypto.randomUUID(),
      userId: "366208102539984896",
      borderColor: "#ff8080",
      label: "プレイヤー1",
    },
  ]);

  // 全体設定（色のみ、ラベルのみ、両方）
  let globalSetting: GlobalSettings = $state("both");

  // 生成されたCSS
  let generatedCSS: string = $state("");

  // プレビュー用のサンプルユーザー名
  const sampleUsernames = [
    "ミズノフ",
    "プレイヤー2",
    "プレイヤー3",
    "プレイヤー4",
  ];

  // CSSを生成する関数
  function generateCSS() {
    let css = "";

    for (const style of userStyles) {
      if (style.userId) {
        if (
          (globalSetting === "border" || globalSetting === "both") &&
          style.borderColor
        ) {
          css += `[data-userid="${style.userId}"] .voice_avatar {\n  border-color: ${style.borderColor};\n}\n\n`;
        }

        if (
          (globalSetting === "label" || globalSetting === "both") &&
          style.label
        ) {
          css += `[data-userid="${style.userId}"] .voice_username::after {\n  content: "${style.label}";\n}\n\n`;
        }
      }
    }

    if (css === "") {
      generatedCSS =
        "// ユーザーIDを入力し、設定に応じてボーダー色やラベルを入力してください";
    } else {
      generatedCSS = css.trim();
    }
  }

  // クリップボードにコピーする関数
  function copyToClipboard() {
    navigator.clipboard.writeText(generatedCSS);
  }

  // 新しいユーザースタイルを追加
  function addUserStyle() {
    userStyles = [
      ...userStyles,
      {
        id: crypto.randomUUID(),
        userId: "",
        borderColor: "#ff8080",
        label: "",
      },
    ];
  }

  // ユーザースタイルを削除
  function removeUserStyle(id: string) {
    userStyles = userStyles.filter((style) => style.id !== id);
  }

  // フルCSSをコピー
  function copyFullCSS() {
    const preElement = document.querySelector(".full-css pre");
    if (preElement) {
      navigator.clipboard.writeText(preElement.textContent || "");
    }
  }

  // 入力が変更されたらCSSを更新
  $effect(() => {
    generateCSS();
  });

  // プレビュー用のスタイルを生成
  function getPreviewStyle() {
    let style = "";
    for (const userStyle of userStyles) {
      if (userStyle.userId) {
        if (
          (globalSetting === "border" || globalSetting === "both") &&
          userStyle.borderColor
        ) {
          style += `
            [data-userid="${userStyle.userId}"] .voice_avatar {
              border-color: ${userStyle.borderColor} !important;
            }
          `;
        }
        if (
          (globalSetting === "label" || globalSetting === "both") &&
          userStyle.label
        ) {
          style += `
            [data-userid="${userStyle.userId}"] .voice_username::after {
              content: "${userStyle.label}";
            }
          `;
        }
      }
    }
    return style;
  }
</script>

<div class="style-form">
  <h2>Discord ユーザースタイルジェネレーター</h2>

  <!-- 全体設定 -->
  <div class="global-settings">
    <h3>全体設定</h3>
    <div class="setting-group">
      <label>適用するスタイル:</label>
      <div class="radio-group">
        <label class="radio-option">
          <input type="radio" bind:group={globalSetting} value="border" />
          ボーダー色のみ
        </label>
        <label class="radio-option">
          <input type="radio" bind:group={globalSetting} value="label" />
          ラベルのみ
        </label>
        <label class="radio-option">
          <input type="radio" bind:group={globalSetting} value="both" />
          ボーダー色とラベル両方
        </label>
      </div>
    </div>
  </div>

  <!-- プレビュー -->
  <div class="preview-section">
    <h3>プレビュー</h3>
    <div class="preview-container">
      <!-- プレビュー用スタイル -->
      <style>
        {getPreviewStyle()}
      </style>

      <div class="voice_container">
        <ul class="voice_states">
          {#each userStyles.slice(0, 4) as style, index}
            {#if style.userId}
              <li class="voice_state" data-userid={style.userId}>
                <div class="voice_avatar"></div>
                <div class="voice_username">
                  <span class="voice_name">
                    {sampleUsernames[index] || `ユーザー${index + 1}`}
                  </span>
                </div>
              </li>
            {/if}
          {/each}
        </ul>
      </div>
    </div>
  </div>

  {#each userStyles as style (style.id)}
    <div class="user-style-card">
      <div class="card-header">
        <h3>ユーザー設定</h3>
        {#if userStyles.length > 1}
          <button
            class="remove-button"
            onclick={() => removeUserStyle(style.id)}>削除</button
          >
        {/if}
      </div>

      <div class="form-group">
        <label for="user-id-{style.id}">Discord ユーザーID:</label>
        <input
          id="user-id-{style.id}"
          type="text"
          bind:value={style.userId}
          placeholder="例: 366208102539984896"
        />
      </div>

      {#if globalSetting === "border" || globalSetting === "both"}
        <div class="form-group">
          <label for="border-color-{style.id}">ボーダー色:</label>
          <input
            id="border-color-{style.id}"
            type="color"
            bind:value={style.borderColor}
          />
        </div>
      {/if}

      {#if globalSetting === "label" || globalSetting === "both"}
        <div class="form-group">
          <label for="label-{style.id}">ラベル:</label>
          <input
            id="label-{style.id}"
            type="text"
            bind:value={style.label}
            placeholder="ラベルテキスト"
          />
        </div>
      {/if}
    </div>
  {/each}

  <button class="add-button" onclick={addUserStyle}>ユーザーを追加</button>

  <div class="output">
    <h3>生成されたCSS</h3>
    <div class="code-container">
      <pre>{generatedCSS}</pre>
      <button class="copy-button" onclick={copyToClipboard}>コピー</button>
    </div>

    <div class="full-css">
      <h3>完全なCSS (OBSにコピー)</h3>
      <pre>{`body {
    background-color: rgba(0, 0, 0, 0);
    margin: 0px auto;
    overflow: hidden;
}

.voice_state {
    display: flex;
    align-items: center;
    padding-top: 28px;
    padding-bottom: 28px;
}

.voice_avatar {
    width: 80px;
    height: 80px;
    margin-right: 11px;
    padding: 3px !important;
    border: 5px solid transparent;
    filter: brightness(80%);
    transition: filter 0.1s ease;
}

.wrapper_speaking .voice_avatar {
    filter: none;
    transition: filter 0.1s ease;
}

${userStyles
  .filter(
    (s) =>
      s.userId &&
      (globalSetting === "border" || globalSetting === "both") &&
      s.borderColor
  )
  .map(
    (s) =>
      `[data-userid="${s.userId}"] .voice_avatar {
    border-color: ${s.borderColor};
}`
  )
  .join("\n\n")}

.voice_username {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
    margin-bottom: 16px;
}

.voice_username span {
    display: flex;
    align-items: center;
    font-size: 20px !important;
    padding-left: 6px !important;
    padding-right: 6px !important;
    border-radius: 3px !important;
    height: 26px;
    color: white;
    background-color: rgba(30, 33, 36, 0.95);
}

.voice_username::after {
    display: flex;
    align-items: center;
    font-size: 14px;
    padding-left: 6px;
    padding-right: 6px;
    border-radius: 3px;
    height: 22px;
    color: white;
    background-color: rgba(90, 99, 108, 0.95);
}

${userStyles
  .filter(
    (s) =>
      s.userId &&
      (globalSetting === "label" || globalSetting === "both") &&
      s.label
  )
  .map(
    (s) =>
      `[data-userid="${s.userId}"] .voice_username::after {
    content: "${s.label}";
}`
  )
  .join("\n\n")}`}</pre>
      <button class="copy-button" onclick={copyFullCSS}>全CSSをコピー</button>
    </div>
  </div>
</div>

<style>
  .style-form {
    max-width: 1000px;
    margin: 0 auto;
    padding: 20px;
  }

  .global-settings {
    border: 2px solid #646cff;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 32px;
    background-color: #f8f9ff;
  }

  .global-settings h3 {
    margin: 0 0 16px 0;
    color: #646cff;
  }

  .setting-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .radio-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .radio-option {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
  }

  .radio-option input[type="radio"] {
    cursor: pointer;
  }

  /* プレビューセクション */
  .preview-section {
    border: 2px solid #4caf50;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 32px;
    background-color: #f8fff8;
  }

  .preview-section h3 {
    margin: 0 0 16px 0;
    color: #4caf50;
  }

  .preview-container {
    background-color: rgba(0, 0, 0, 0.8);
    border-radius: 8px;
    padding: 20px;
    min-height: 200px;
  }

  /* Discord Overlay スタイル再現 */
  .voice_container {
    background-color: transparent;
  }

  .voice_states {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .voice_state {
    display: flex;
    align-items: center;
    padding-top: 12px;
    padding-bottom: 12px;
  }

  .voice_avatar {
    width: 40px;
    height: 40px;
    margin-right: 8px;
    padding: 2px;
    border: 3px solid transparent;
    border-radius: 50%;
    background: linear-gradient(45deg, #7289da, #99aab5);
    filter: brightness(80%);
    transition: filter 0.1s ease;
  }

  .voice_username {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
    margin-bottom: 8px;
  }

  .voice_username .voice_name {
    display: flex;
    align-items: center;
    font-size: 14px;
    padding-left: 6px;
    padding-right: 6px;
    border-radius: 3px;
    height: 20px;
    color: white;
    background-color: rgba(30, 33, 36, 0.95);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
      sans-serif;
  }

  .voice_username::after {
    display: flex;
    align-items: center;
    font-size: 12px;
    padding-left: 6px;
    padding-right: 6px;
    border-radius: 3px;
    height: 18px;
    color: white;
    background-color: rgba(90, 99, 108, 0.95);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
      sans-serif;
  }

  .user-style-card {
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 24px;
    background-color: #f9f9f9;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  .card-header h3 {
    margin: 0;
  }

  .form-group {
    margin-bottom: 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  input[type="text"] {
    padding: 8px;
    border-radius: 4px;
    border: 1px solid #ccc;
    width: 100%;
  }

  input[type="color"] {
    height: 40px;
    width: 100px;
  }

  .add-button {
    background-color: #4caf50;
    color: white;
    border: none;
    padding: 10px 15px;
    border-radius: 4px;
    cursor: pointer;
    font-weight: bold;
    margin-bottom: 24px;
  }

  .add-button:hover {
    background-color: #45a049;
  }

  .remove-button {
    background-color: #f44336;
    color: white;
    border: none;
    padding: 5px 10px;
    border-radius: 4px;
    cursor: pointer;
  }

  .remove-button:hover {
    background-color: #d32f2f;
  }

  .code-container {
    position: relative;
    margin-top: 10px;
  }

  pre {
    background-color: #f4f4f4;
    padding: 15px;
    border-radius: 4px;
    overflow-x: auto;
    white-space: pre-wrap;
    word-wrap: break-word;
  }

  .copy-button {
    position: absolute;
    top: 10px;
    right: 10px;
    padding: 5px 10px;
    background-color: #646cff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }

  .copy-button:hover {
    background-color: #535bf2;
  }

  .full-css {
    margin-top: 30px;
    position: relative;
  }

  .full-css .copy-button {
    position: static;
    margin-top: 10px;
  }

  .output {
    margin-top: 24px;
  }
</style>
