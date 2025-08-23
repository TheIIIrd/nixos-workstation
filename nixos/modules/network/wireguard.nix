{
  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        ips = [ "10.0.0.2/24" ];
        listenPort = 51820;

        # privateKeyFile = "PATH_TO_PRIVATE_KEY_FILE";
        privateKey = "CLIENT_PRIVATE_KEY";

        peers = [
          {
            publicKey = "SERVER_PUBLIC_KEY";

            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "SERVER_IP:51820";

            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
