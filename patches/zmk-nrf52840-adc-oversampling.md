# nRF52840 ADC oversampling fix for zmk-analog-input-driver

The analog thumbstick driver polls the nRF52840 SAADC. On this chip the
`oversampling` field of `adc_sequence` is unsupported in the mode the
driver uses, and if left non-zero the ADC reads STALL after ~1 minute
(stick goes dead until reboot).

The driver author's fix: ground every `adc_sequence::oversampling` to 0 in
the ZMK source you build against.

## How to apply in a zmk-workspace (west) build

ZMK is pulled as a west project at `zmk/` after `just init` / `west update`.
The field appears in battery + any SAADC sequence setup. Search and zero it:

```sh
cd zmk-workspace
grep -rn "oversampling" zmk/app/ modules/ 2>/dev/null
```

Then set each `.oversampling = N` to `.oversampling = 0` (or remove the
assignment so it defaults to 0). The canonical spot the driver author
points at is the VDDH battery sensor sequence:

  zmk/app/module/drivers/sensor/battery/battery_nrf_vddh.c

```c
.oversampling = 0,   /* was a non-zero value; SAADC poll mode needs 0 */
```

## Cleaner: pin a ZMK fork that already has the fix

Rather than patching post-checkout (which `west update` can clobber), point
`config/west.yml` at a ZMK fork/revision that already zeroes oversampling.
If you maintain your own ZMK fork (common in r2d2rogers/zmk-workspace-style
setups), apply the one-line change there and pin its revision in the
manifest:

```yaml
  projects:
    - name: zmk
      remote: <your-remote>   # your fork
      revision: <sha-with-oversampling-fix>
      import: app/west.yml
```

## CI note

In GitHub Actions builds the checkout is fresh each run, so a fork pin is
the only durable option — a post-checkout `sed` step in the workflow also
works but is fragile across ZMK refactors. Recommended: fork + pin.
