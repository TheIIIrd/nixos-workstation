{
  networking = {
    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
    };

    nameservers = [ "9.9.9.9" "149.112.112.112" ];

    firewall = {
      enable = true;
      allowPing = false;
      # allowedTCPPorts = [ 25565 ];
      # allowedUDPPorts = [ 25565 ];
    };
  };
}
