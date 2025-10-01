{
  networking = {
    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
    };

    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = [ 25565 51820 ];
      allowedUDPPorts = [ 25565 51820 ];
    };
  };
}
