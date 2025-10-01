{ pkgs, ... }: {
  networking = {
    nameservers = [ "127.0.0.1" "::1" ];
    networkmanager.dns = "none";
  }

  services.stubby = {
    enable = true;

    settings = pkgs.stubby.passthru.settingsExample // {
      upstream_recursive_servers = [{
        address_data = "9.9.9.9";
        tls_auth_name = "dns.quad9.net";

        tls_pubkey_pinset = [{
          digest = "sha256";
          value = "i2kObfz0qIKCGNWt7MjBUeSrh0Dyjb0/zWINImZES+I=";
        }];
      } {
        address_data = "149.112.112.112";
        tls_auth_name = "dns.quad9.net";

        tls_pubkey_pinset = [{
          digest = "sha256";
          value = "i2kObfz0qIKCGNWt7MjBUeSrh0Dyjb0/zWINImZES+I=";
        }];
      } {
        address_data = "1.1.1.1";
        tls_auth_name = "cloudflare-dns.com";

        tls_pubkey_pinset = [{
          digest = "sha256";
          value = "SPfg6FluPIlUc6a5h313BDCxQYNGX+THTy7ig5X3+VA=";
        }];
      } {
        address_data = "1.0.0.1";
        tls_auth_name = "cloudflare-dns.com";

        tls_pubkey_pinset = [{
          digest = "sha256";
          value = "SPfg6FluPIlUc6a5h313BDCxQYNGX+THTy7ig5X3+VA=";
        }];
      }];
    };
  };
}
