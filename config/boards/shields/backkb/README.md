# backkb — ZMK shield for the S24 Ultra back-of-phone split

Drop-in shield for the **urob-style `zmk-workspace`** layout (which
`r2d2rogers/zmk-workspace` follows). 32 keys: 5 columns per hand (index
finger has a 2nd inboard column) × 3 rows + 1 thumb each, **plus per side a
clickable scroll wheel (rotary encoder) and an analog thumbstick**. Two
nice!nano v2 halves, BLE split, BLE HID to Android.

## Pointing devices

Per side, on the front/side edge under the thumb tip:
- **Scroll wheel** = EC11 rotary encoder. Native ZMK. `sensor-bindings`
  per layer: volume on BASE, page scroll on SYM, mouse scroll on MOUSE.
- **Analog thumbstick** (PSP-flat, dual-pot) = `badjeff/zmk-analog-input-driver`
  reading 2 ADC channels. Layer-switchable behavior:
  - BASE/MOUSE -> mouse cursor (REL_X/REL_Y)
  - SCROLL -> scroll (via `zip_xy_to_scroll_mapper` input processor)
  - GAMEPAD -> HID joystick axes (via `badjeff/zmk-hid-io`)

### Important caveats (read before building)
1. **Battery:** the analog driver polls the ADC continuously and the author
   marks it *not recommended for wireless builds*. This rig is intended to
   run **USB-tethered most of the time**. Off-tether, stay on BASE (no
   pointer polling) so the MCU can sleep.
2. **nRF52840 ADC fix REQUIRED:** without zeroing `adc_sequence::oversampling`
   in your ZMK source, analog reads stall after ~1 minute. See
   `patches/zmk-nrf52840-adc-oversampling.md`. Recommended: fork ZMK, zero
   the field, pin that revision in `west.yml`.
3. **Layer-filter leak (zmk #2967):** on some ZMK revisions the `layers`
   filter on input-listener children doesn't fully restrict a processor.
   If scroll stays active off-layer, pin a ZMK rev past the fix.

## Where files go in your workspace

```
zmk-workspace/
├── build.yaml                                  <- merge the include: entries
├── patches/
│   └── zmk-nrf52840-adc-oversampling.md
└── config/
    ├── west.yml                                <- ZMK + badjeff modules
    ├── backkb.keymap                           <- BASE/SYM/NUM/MOUSE/SCROLL/GAMEPAD
    └── boards/shields/backkb/
        ├── Kconfig.shield
        ├── Kconfig.defconfig
        ├── backkb.zmk.yml
        ├── backkb.dtsi                         <- MATRIX kscan + encoder + sensors
        ├── backkb_left.overlay                 <- matrix + wheel + stick (L)
        ├── backkb_right.overlay                <- matrix + wheel + stick (R)
        └── backkb.conf                         <- pointer/analog/hid-io flags
```

If you already have a `west.yml`, merge the `badjeff` remote + the
`zmk-analog-input-driver` and `zmk-hid-io` projects into it rather than
overwriting.

## Wiring — now a MATRIX (diodes required)

Converting from direct-wire to a **4x5 matrix** (20 cells) frees the GPIO
the sticks + encoders need. Per side:
- Matrix: 4 row + 5 col = **9 pins**, with a **1N4148 diode per key**,
  band (cathode) toward the row (`diode-direction = "col2row"`).
- Encoder: 2 pins (A/B). Wheel click rides a matrix cell.
- Thumbstick: 2 ADC pins (X/Y). Stick click rides a matrix cell.
- Total ~13 pins/side — fits the nice!nano.

The matrix wires 18 inputs (15 keys + thumb + 2 clicks) into 20 cells; map
the 2 clicks to spare cells. The 32-key visual grid in the keymap is
unchanged — clicks are bound via behaviors, not as grid keys.

### ADC channel pins (nRF52840)
The overlays use `io-channels = <&adc 2>` (X) and `<&adc 3>` (Y). Per the
driver's `ain-map.png`, ADC channel N maps to a specific P0.xx pin — wire
your stick wipers to the pins for the channels you pick, set
`mv-mid`/`mv-min-max` to your stick's measured center/range, and tune
`scale-divisor` for sensitivity.

## Build

```
just build backkb_left
just build backkb_right
# or: just build all   (uses build.yaml)
```

UF2s -> `firmware/`. Flash `settings_reset` first when re-pairing.

## Layout (BASE)

```
 outer:  q w e r | t      y | u i o p
 home:   a s d f | g      h | j k l ;     (a/s/d/f & j/k/l/; = homerow mods)
 inner:  z x c v | b      n | m , . /
 thumb:      [SPC/SYM]         [BSPC/NUM]
 wheels: volume      sticks: cursor (hold SYM->MOUSE; NUM exposes SCROLL/GAMEPAD)
```

You said you'd map the per-layer stick behavior yourself — the hooks are
all wired (MOUSE/SCROLL/GAMEPAD layers + input-processors + hid-io). Remap
the `&mo` access keys and gamepad button bindings to taste.
