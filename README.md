# qmk-ap2

Anne Pro 2 C18 (QMK) build tree. QMK, AnnePro2-Shine, and AnnePro2-Tools are
git submodules pinned to the commits used for this keyboard.

Hardware: Anne Pro 2 C18, ANSI, internal battery removed. Bluetooth keys are
removed from FN2.

## Layout

- `qmk_firmware/` — fork of `qmk/qmk_firmware`, branch `ap2-c18`
  - LED UART baud fixed to 57600 (QMK issue #23900)
  - custom keymap in `default`, `default-full-caps`, `default-layer-indicators`
- `AnnePro2-Shine/` — fork of `OpenAnnePro/AnnePro2-Shine`, branch `ap2-uart`
  - LED UART baud fixed to 57600 to match QMK
- `AnnePro2-Tools/` — fork of `OpenAnnePro/AnnePro2-Tools`, `master`, unchanged

## Keymap

- Base: standard ANSI, Caps Lock plain, Alt/Gui swapped for Mac, `RSFT_T(KC_UP)`
- Fn1: F-row, arrows on WASD, Home/End/PgUp/PgDn, Ins/Del
- Fn2: RGB controls on the top row from `1`, arrows, media, volume; no Bluetooth
- Global tap-hold settings in `qmk_firmware/keyboards/annepro2/config.h`:
  `TAPPING_TERM 150` and `HOLD_ON_OTHER_KEY_PRESS`

The layout itself lives in `qmk_firmware/keyboards/annepro2/keymaps/ap2_common.h`;
the three ANSI keymaps include it and only add their LED behaviour.

## Build

Prerequisites:

```bash
sudo pacman -S arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-newlib hidapi
python3 -m pip install --user qmk
```

From the repo root:

```bash
make                    # annepro2/c18, default (custom layout)
make qmk-full-caps
make qmk-layer-indicators
make shine              # C18 Shine
make tools              # annepro2_tools
```

The standard QMK commands also work inside `qmk_firmware`:

```bash
cd qmk_firmware
make annepro2/c18
make annepro2/c18:default-full-caps
make annepro2/c18:default-layer-indicators
```

Outputs:

```text
qmk_firmware/.build/annepro2_c18_default.bin
qmk_firmware/.build/annepro2_c18_default-full-caps.bin
qmk_firmware/.build/annepro2_c18_default-layer-indicators.bin
AnnePro2-Shine/build/annepro2-shine-C18.bin
```

## Flash

Put the keyboard into IAP mode: unplug it, hold `Esc`, plug it back in.

First flash after the UART change (both MCUs must match):

```bash
sudo ./AnnePro2-Tools/target/release/annepro2_tools \
  qmk_firmware/.build/annepro2_c18_default.bin
sudo ./AnnePro2-Tools/target/release/annepro2_tools --boot -t led \
  AnnePro2-Shine/build/annepro2-shine-C18.bin
```

The first command intentionally has no `--boot`, so the main MCU stays in IAP
for the LED MCU flash. For later keymap-only changes:

```bash
sudo ./AnnePro2-Tools/target/release/annepro2_tools --boot \
  qmk_firmware/.build/annepro2_c18_default.bin
```

Or use the shortcuts:

```bash
make flash                  # main MCU only, with --boot
make flash-full-caps
make flash-layer-indicators
make flash-all              # QMK + Shine, no --boot on the first
```

## Notes

- The OpenAnnePro QMK fork is archived; this uses upstream `qmk/qmk_firmware`.
- `LSHIFT + RSHIFT + B` is not implemented in current upstream QMK. Use `Esc`
  for IAP.
- To update from upstream:

  ```bash
  cd qmk_firmware
  git remote add upstream https://github.com/qmk/qmk_firmware.git   # once
  git fetch upstream
  git rebase upstream/master
  ```

  The UART change and the three keymap wrappers may conflict; the shared layout
  in `ap2_common.h` is not touched by upstream.
