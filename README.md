# Zephyr SDK for Workshop

This SDK provides the Zephyr RTOS source tree and build tools (west,
cmake, ninja) for embedded firmware development. A companion `zephyr-sdk-ng`
SDK provides the toolchain bundle, and individual toolchain SDKs (e.g.
`zephyr-amd64`) supply architecture-specific cross-compilers. The `venv` plug
should be connected to a venv provider such as the `uv` SDK. The Zephyr build
cache and Python virtual environment are persisted on the host across workshop
updates.

### Compatibility matrix

| SDK NG / Toolchain | Zephyr |
|---|---|
| 1.1.x | 4.5.x |
| 1.0.x | 4.4.x |
| 0.17.x | 4.2.x, 4.3.x |

The `zephyr` SDK's `check-health` hook verifies this compatibility at runtime.

---

## Reference workshop

A minimal usable workshop:

```yaml
# workshop.yaml
name: dev
base: ubuntu@24.04
sdks:
  - name: uv
    channel: latest/stable
  - name: zephyr
    channel: 4.4/stable
  - name: zephyr-sdk-ng
    channel: 1.0.1/stable
  - name: zephyr-amd64
    channel: 1.0.1/stable

actions:
  build-amd64: |-
    for DIRNAME in */; do
        DIRNAME=${DIRNAME%/}
        [[ $DIRNAME == build* ]] && continue

        cmake -GNinja \
            -S "${DIRNAME}/" \
            -B "build-${DIRNAME}-amd64" \
            -DBUILD_VERSION="$ZEPHYR_VERSION" \
            -DBOARD=qemu_x86 \
            -DCROSS_COMPILE="$ZEPHYR_SDK_INSTALL_DIR/x86_64-zephyr-elf/bin/x86_64-zephyr-elf-"

        ninja -C "build-${DIRNAME}-amd64"
    done

connections:
  - plug: zephyr:sdk-ng
    slot: zephyr-sdk-ng:sdk-ng
  - plug: zephyr-sdk-ng:amd64
    slot: zephyr-amd64:toolchain
  - plug: zephyr:venv
    slot: uv:venv
```

---

## Using the SDK

### Prerequisites

1. The `zephyr-sdk-ng` SDK is required — it provides the SDK NG bundle
   (host tools, CMake toolchain files). Connect the `sdk-ng` plug on `zephyr`
   to the `sdk-ng` slot on `zephyr-sdk-ng`.
2. At least one toolchain SDK (e.g. `zephyr-amd64`) is required. Connect its
   `toolchain` slot to the matching architecture plug on `zephyr-sdk-ng`.
3. A venv provider is required. Connect the `venv` plug to the `uv` SDK (or
   another provider). On first launch, the SDK installs `west` into this venv.

### Build firmware

Place your Zephyr application directories in your project root. Then run the
`build-amd64` action from the example workshop above:

```bash
workshop run build-amd64
```

`ZEPHYR_BASE` and `ZEPHYR_SDK_INSTALL_DIR` are set automatically by the
`setup-project` hook.

---

## Plugs (resources this SDK consumes)

### `sdk-ng`

- Interface: `mount`
- Workshop target: `$SDK/zephyr-sdk`
- Purpose: Receives the SDK NG bundle from `zephyr-sdk-ng`. This provides
  host tools, CMake toolchain files, and mount points for architecture-specific
  toolchains. The `check-health` hook verifies that this plug is connected and
  that the SDK NG version is compatible with the Zephyr version.

### `zephyr-cache`

- Interface: `mount`
- Workshop target: `/home/workshop/.cache/zephyr`
- Purpose: Persists the Zephyr build cache across workshop updates.

### `modules`

- Interface: `mount`
- Workshop target: `/home/workshop/modules`
- Purpose: Mount point for extra Zephyr modules such as `hal_espressif` from
  companion SDKs.

### `venv`

- Interface: `mount`
- Workshop target: `$SDK/venv`
- Purpose: Receives a Python virtual environment from an external provider
  (e.g. the `uv` SDK). The `setup-project` hook installs west into this venv.
  Persisted on the host across workshop updates.

## Slots (resources this SDK provides)

This SDK doesn't define any slots.

---

## Documentation and guidance

- [Zephyr official documentation](https://docs.zephyrproject.org/latest/)
- [Zephyr getting started guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html)
- [Workshop documentation](https://ubuntu.com/workshop/docs/)

---

## Community and support

- Zephyr community: [Zephyr GitHub](https://github.com/zephyrproject-rtos/zephyr)
- Zephyr community forum: [Zephyr Discord](https://chat.zephyrproject.org/)
- Workshop forum:
  [Discourse](https://discourse.ubuntu.com/)
- Please review our
  [Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct) before
  participating.

---

## Contributions

All contributions, including code, documentation updates, and issue reports,
are welcome!

- See `CONTRIBUTING.md` for guidelines.
- Open issues or pull requests on the official repository.

---

## License and copyright

Copyright 2025 Canonical Ltd.

The Zephyr RTOS is licensed under the
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
