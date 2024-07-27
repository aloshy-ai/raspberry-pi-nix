# raspberry-pi-nix

The primary goal of this flake is to make it easy to create
working NixOS configurations for Raspberry Pi products. Specifically,
this repository aims to deliver the following benefits:

1. Configure the kernel, device tree, and boot loader in a way that is
   compatible with the hardware and proprietary firmware.
2. Provide a nix interface to Raspberry Pi/device tree configuration
   that will be familiar to those who have used Raspberry Pi's
   [config.txt based
   configuration](https://www.raspberrypi.com/documentation/computers/config_txt.html).
3. Make it easy to build an image suitable for flashing to an sd-card,
   without the need to first go through an installation media.

The important modules are `overlay/default.nix`, `rpi/default.nix`,
and `rpi/config.nix`. The other modules are mostly wrappers that set
`config.txt` settings and enable required kernel modules.

## Example

See the `rpi-example` config in this flake for a CI-checked example.

```nix
{
  description = "raspberry-pi-nix example";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      basic-config = { pkgs, lib, ... }: {
        # bcm2711 for rpi 3, 3+, 4, zero 2 w
        # bcm2712 for rpi 5
        # See the docs at:
        # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
        raspberry-pi-nix.board = "bcm2711";
        time.timeZone = "America/New_York";
        users.users.root.initialPassword = "root";
        networking = {
          hostName = "basic-example";
          useDHCP = false;
          interfaces = {
            wlan0.useDHCP = true;
            eth0.useDHCP = true;
          };
        };
        hardware = {
          bluetooth.enable = true;
          raspberry-pi = {
            config = {
              all = {
                base-dt-params = {
                  # enable autoprobing of bluetooth driver
                  # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                  krnbt = {
                    enable = true;
                    value = "on";
                  };
                };
              };
            };
          };
        };
      };

    in {
      nixosConfigurations = {
        rpi-example = nixosSystem {
          system = "aarch64-linux";
          modules = [ raspberry-pi-nix.nixosModules.raspberry-pi basic-config ];
        };
      };
    };
}
```

## Using the provided cache to avoid compiling linux
This repo uses the raspberry pi linux kernel fork, and compiling linux takes a
while. CI pushes kernel builds to the nix-community cachix cache that you may
use to avoid compiling linux yourself. The cache can be found at
https://nix-community.cachix.org, and you can follow the instructions there
to use this cache.

You don't need the cachix binary to use the cachix cache though, you
just need to add the relevant
[`substituters`](https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=nix.conf#conf-substituters)
and
[`trusted-public-keys`](https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=nix.conf#conf-trusted-public-keys)
settings settings to your `nix.conf`. You can do this directly by
modifying your `/etc/nix/nix.conf`, or in the flake definition. In the
above example flake these `nix.conf` settings are added by the
`nixConfig` attribute ([doc
link](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html?highlight=flake#flake-format)).
Note that this will only work if the user running `nix build` is in
[`trusted-users`](https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=nix.conf#conf-trusted-users)
or the substituter is in
[`trusted-substituters`](https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=nix.conf#conf-trusted-substituters).

## Building an sd-card image

An image suitable for flashing to an sd-card can be found at the
attribute `config.system.build.sdImage`. For example, if you wanted to
build an image for `rpi-example` in the above configuration
example you could run:

```
nix build '.#nixosConfigurations.rpi-example.config.system.build.sdImage'
```

## The firmware partition

The image produced by this package is partitioned in the same way as the aarch64
installation media from nixpkgs: There is a firmware partition that contains
necessary firmware, the kernel or u-boot, and config.txt. Then there is another
partition (labeled `NIXOS_SD`) that contains everything else. The firmware and
`config.txt` file are managed by NixOS modules defined in this
package. Additionally, a systemd service will update the firmware and
`config.txt` in the firmware partition __in place__. If uboot is enabled then
linux kernels are stored in the `NIXOS_SD` partition and will be booted by
u-boot in the firmware partition.

## `config.txt` generation

As noted, the `config.txt` file is generated by the NixOS
configuration and automatically updated on when the nix configuration
is modified. 

The relevant nixos option is
`hardware.raspberry-pi.config`. Configuration is partitioned into
three sections:

1. Base device tree parameters `base-dt-params`
2. Device tree overlays `dt-overlays`
3. Firmware options `options`

Other than that, the format follows pretty closely to the config.txt
format. For example:

```nix
hardware.raspberry-pi.config = {
  cm4 = {
    options = {
      otg_mode = {
        enable = true;
        value = true;
      };
    };
  };
  pi4 = {
    options = {
      arm_boost = {
        enable = true;
        value = true;
      };
    };
    dt-overlays = {
      vc4-kms-v3d = {
        enable = true;
        params = { cma-512 = { enable = true; }; };
      };
    };
  };
  all = {
    options = {
      # The firmware will start our u-boot binary rather than a
      # linux kernel.
      kernel = {
        enable = true;
        value = "u-boot-rpi-arm64.bin";
      };
      arm_64bit = {
        enable = true;
        value = true;
      };
      enable_uart = {
        enable = true;
        value = true;
      };
      avoid_warnings = {
        enable = true;
        value = true;
      };
      camera_auto_detect = {
        enable = true;
        value = true;
      };
      display_auto_detect = {
        enable = true;
        value = true;
      };
      disable_overscan = {
        enable = true;
        value = true;
      };
    };
    dt-overlays = {
      vc4-kms-v3d = {
        enable = true;
        params = { };
      };
    };
    base-dt-params = {
      krnbt = {
        enable = true;
        value = "on";
      };
      spi = {
        enable = true;
        value = "on";
      };
    };
  };
};
```

generates the following config.txt:

```
# This is a generated file. Do not edit!
[all]
arm_64bit=1
avoid_warnings=1
camera_auto_detect=1
disable_overscan=1
display_auto_detect=1
enable_uart=1
kernel=u-boot-rpi-arm64.bin
dtparam=krnbt=on
dtparam=spi=on
dtoverlay=vc4-kms-v3d

dtoverlay=

[cm4]
otg_mode=1

[pi4]
arm_boost=1
dtoverlay=vc4-kms-v3d
dtparam=cma-512
dtoverlay=
```

If you want to preview the generated `config.txt`, you can find
it at the path `config.hardware.raspberry-pi.config-output`. For
example, if you had the above configuration then you could build the
`config.txt` file with:

```
nix build '.#nixosConfigurations.rpi-example.config.hardware.raspberry-pi.config-output'
```

## Firmware partition implementation notes

In Raspberry Pi devices the proprietary firmware manipulates the device tree in
a number of ways before handing it off to the kernel (or in our case, to
u-boot). The transformations that are performed aren't documented so well
(although I have found [this
list](https://forums.raspberrypi.com/viewtopic.php?t=329799#p1974233) ).

This manipulation makes it difficult to use the device tree configured directly
by NixOS as the proprietary firmware's manipulation must be known and
reproduced.

Even if the manipulation were successfully reproduced, some benefits would be
lost. For example, the firmware can detect connected hardware during boot and
automatically configure the device tree accordingly before passing it onto the
kernel. If this firmware device tree is ignored then a NixOS system rebuild with
a different device tree would be required when swapping connected
hardware. Examples of what I mean by hardware include: the specific Raspberry Pi
device booting the image, connected cameras, and connected displays.

So, in order to avoid the headaches associated with failing to reproduce some
firmware device tree manipulation, and to reap the benefits afforded by the
firmware device tree configuration, the bootloader is configured to use the
device tree that it is given (i.e. the one that the raspberry pi firmware loads
and manipulates). As a consequence, device tree configuration is controlled via
the [config.txt
file](https://www.raspberrypi.com/documentation/computers/config_txt.html).

Additionally, the firmware, device trees, and overlays from the `raspberrypifw`
package populate the firmware partition. This package is kept up to date by the
overlay applied by this package, so you don't need configure this. However, if
you want to use different firmware you can override that package to do so.

## What's not working?
- [ ] Pi 5 u-boot devices other than sd-cards (i.e. usb, nvme).
