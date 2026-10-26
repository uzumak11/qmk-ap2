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
- `AnnePro2-Tools/` — fork of `OpenAnnePro/AnnePro2-Tools`, `master`

The shared layout is `qmk_firmware/keyboards/annepro2/keymaps/ap2_common.h`;
the three ANSI keymaps include it and only add their LED behaviour.

## Keymap

### Base

```text
Esc    1    2    3    4    5    6    7    8    9    0    -    =    Bksp
Tab    Q    W    E    R    T    Y    U    I    O    P    [    ]    \
Caps   A    S    D    F    G    H    J    K    L    ;    '    Enter
LShift Z    X    C    V    B    N    M    ,    .    /    RShift/Up
LCtrl  LAlt LGui Space RAlt Fn1/← Fn2/↓ RCtrl/→
```

### Fn1 — hold `Fn1/←`

```text
`      F1   F2   F3   F4   F5   F6   F7   F8   F9   F10  F11  F12  Del
_      _    Up   _    _    _    _    _    _    _    Pscr Home End  _
_      ←    ↓    →    _    _    _    _    _    _    PgUp PgDn _
_      _    _    _    _    _    _    _    _    Ins  Del  _
_      _    _    _    _    _    Fn2  _
```

### Fn2 — hold `Fn2/↓` (or Fn1 + Fn2)

```text
_      TOG  NEXT PREV HUE- HUE+ SAT- SAT+ VAL- VAL+ SPD- SPD+ _    Del
_      _    Up   _    _    _    _    _    _    _    _    _    _    _
_      ←    ↓    →    _    _    _    _    _    MPRV MPLY MNXT _
_      _    _    _    _    _    _    _    Vol- Vol+ Mute _
_      _    _    _    _    _    _    _
```

Legend:

- `_` = transparent; the key falls through to the layer below.
- `RShift/Up` = tap `Up`, hold `Right Shift`.
- `Fn1/←` = tap `Left`, hold `Fn1`.
- `Fn2/↓` = tap `Down`, hold `Fn2`.
- `RCtrl/→` = tap `Right`, hold `Right Ctrl`.
- `TOG`/`NEXT`/`PREV` = `RM_TOGG`/`RM_NEXT`/`RM_PREV`.
- `HUE-`/`HUE+`, `SAT-`/`SAT+`, `VAL-`/`VAL+`, `SPD-`/`SPD+` = the corresponding `RM_*` keys.
- `MPRV`/`MPLY`/`MNXT` = media previous / play-pause / next.
- `Vol-`/`Vol+`/`Mute` = `KC_VOLD`/`KC_VOLU`/`KC_MUTE`.

Caps Lock is plain. There are no Bluetooth keys.

### RGB keycodes

| Diagram | QMK keycode | Action |
|---|---|---|
| `TOG` | `RM_TOGG` | toggle RGB on/off |
| `NEXT` / `PREV` | `RM_NEXT` / `RM_PREV` | next / previous effect |
| `HUE-` / `HUE+` | `RM_HUED` / `RM_HUEU` | hue down / up |
| `SAT-` / `SAT+` | `RM_SATD` / `RM_SATU` | saturation down / up |
| `VAL-` / `VAL+` | `RM_VALD` / `RM_VALU` | brightness down / up |
| `SPD-` / `SPD+` | `RM_SPDD` / `RM_SPDU` | animation speed down / up |

### Tap-hold timing

Global in `qmk_firmware/keyboards/annepro2/config.h`:

```c
#define TAPPING_TERM 150
#define HOLD_ON_OTHER_KEY_PRESS
```

Every mod-tap and layer-tap uses the same 150 ms threshold and the same
hold-on-other-key-press rule.

## Build variants

| Keymap | Build | LEDs |
|---|---|---|
| `default` | `make annepro2/c18` | plain |
| `default-full-caps` | `make annepro2/c18:default-full-caps` | all LEDs red while Caps Lock is on |
| `default-layer-indicators` | `make annepro2/c18:default-layer-indicators` | layer colours + sticky Caps Lock key |

The **full-caps** build is `default-full-caps`.

## Build

Prerequisites:

```bash
sudo pacman -S arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-newlib hidapi
```

QMK CLI. On Arch, `pip install --user` is blocked by PEP 668, so use a local
venv and put its `qmk` on `PATH`:

```bash
python3 -m venv .venv
.venv/bin/pip install qmk
ln -sf "$PWD/.venv/bin/qmk" "$HOME/.local/bin/qmk"
```

Then, from the repo root:

```bash
make                    # annepro2/c18, default (plain)
make qmk-full-caps       # annepro2/c18:default-full-caps
make qmk-layer-indicators
make shine               # C18 Shine
make tools               # annepro2_tools
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
AnnePro2-Shine/build/C18/annepro2-shine-C18.bin
```

## Flash

Put the keyboard into IAP mode: unplug it, hold `Esc`, plug it back in.

### Full caps

First flash after the UART change (QMK full caps + Shine, both MCUs must match):

```bash
make flash-all-full-caps
```

Later keymap-only changes:

```bash
make flash-full-caps
```

Manual equivalent:

```bash
# main MCU, no --boot so it stays in IAP for the LED MCU
sudo ./AnnePro2-Tools/target/release/annepro2_tools \
  qmk_firmware/.build/annepro2_c18_default-full-caps.bin
sudo ./AnnePro2-Tools/target/release/annepro2_tools --boot -t led \
  AnnePro2-Shine/build/C18/annepro2-shine-C18.bin
```

For a later full-caps-only flash:

```bash
sudo ./AnnePro2-Tools/target/release/annepro2_tools --boot \
  qmk_firmware/.build/annepro2_c18_default-full-caps.bin
```

### Other variants

```bash
make flash                    # default (plain)
make flash-layer-indicators   # layer indicators
make flash-all                # default (plain) + Shine
```

## Notes

- The OpenAnnePro QMK fork is archived; this uses upstream `qmk/qmk_firmware`.
- `LSHIFT + RSHIFT + B` is not implemented in current upstream QMK. Use `Esc`
  for IAP.
- This checkout currently uses a user-level ARM toolchain in
  `$HOME/.local/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi`, with
  `arm-none-eabi-*` symlinked into `$HOME/.local/bin`. The pacman command above
  is the equivalent system-wide install.
- To update from upstream:

  ```bash
  cd qmk_firmware
  git remote add upstream https://github.com/qmk/qmk_firmware.git   # once
  git fetch upstream
  git rebase upstream/master
  ```

  The UART change and the three keymap wrappers may conflict; the shared layout
  in `ap2_common.h` is not touched by upstream.
