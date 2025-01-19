{ pkgs, lib, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Asia/Dubai";
  users = {
    users = {
        root = {
        initialPassword = "root";
      };
    };
  };
  networking = {
    hostName = "ETHERPI";
    useDHCP = false;
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
    firewall = {
      allowedTCPPorts = [ 22 ];
      enable = true;
    };
  };
  raspberry-pi-nix.board = "bcm2711";
  hardware = {
    raspberry-pi = {
      config = {
        all = {
          base-dt-params = {
            BOOT_UART = {
              value = 1;
              enable = true;
            };
            uart_2ndstage = {
              value = 1;
              enable = true;
            };
          };
          dt-overlays = {
            disable-bt = {
              enable = true;
              params = { };
            };
          };
        };
      };
    };
  };
  security.rtkit.enable = true;
  services = {
    avahi = {
      enable = true;
      nssmdns = true;
    };
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };
    pipewire = {
       enable = true;
       alsa.enable = true;
       alsa.support32Bit = true;
       pulse.enable = true;
     };
  };
}
