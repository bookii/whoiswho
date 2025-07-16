<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import * as Popover from "$lib/components/ui/popover";
  import { Palette } from "lucide-svelte";
  import { Input } from "./ui/input";
  import { Label } from "./ui/label";

  type Props = {
    colorHex: string;
    onChange: (colorHex: string) => void;
  };
  const { colorHex, onChange }: Props = $props();

  let input = $state(colorHex);
  let open = $state(false);

  const onChangeInput = (event: Event) => {
    if (event.target instanceof HTMLInputElement) {
      input = event.target.value;
      if (/^#[0-9A-F]{6}$/i.test(input)) {
        onChange(input);
      }
    }
  };

  const onChangeColor = (event: Event) => {
    if (event.target instanceof HTMLInputElement) {
      input = event.target.value;
      onChange(input);
    }
  };
</script>

<Popover.Root {open}>
  <Popover.Trigger class="w-full bg-white">
    <Button variant="outline" class="w-full justify-start gap-2 bg-transparent">
      <div
        class="size-4 rounded border border-gray-300"
        style="background-color: {colorHex}"
      ></div>
      {colorHex.toUpperCase()}
      <Palette class="size-4 ml-auto" />
    </Button>
  </Popover.Trigger>
  <Popover.Content class="w-64 p-4 bg-white rounded-lg">
    <div class="space-y-6">
      <div class="space-y-2">
        <Label for="colorHex" class="text-sm">カラーコード</Label>
        <Input type="text" value={colorHex} onchange={onChangeInput} />
      </div>
      <div class="space-y-2">
        <Label for="colorPicker" class="text-sm">カラーピッカー</Label>
        <Input
          id="colorPicker"
          type="color"
          value={colorHex}
          onchange={onChangeColor}
          class="w-full h-10 rounded border border-gray-300 cursor-pointer"
        />
      </div>
    </div>
  </Popover.Content>
</Popover.Root>
