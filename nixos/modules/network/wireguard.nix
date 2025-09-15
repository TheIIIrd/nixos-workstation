{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.0.2/24" ];
      # dns = [ "DNS_SERVER_IP" ];

      # privateKeyFile = "PATH_TO_PRIVATE_KEY_FILE";
      privateKey = "CLIENT_PRIVATE_KEY";

      peers = [
        {
          publicKey = "SERVER_PUBLIC_KEY";

          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "SERVER_IP:51820";

          persistentKeepalive = 25;
        }
      ];
    };
  };
}
