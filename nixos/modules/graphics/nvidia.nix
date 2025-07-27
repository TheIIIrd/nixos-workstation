{ pkgs, config, ... }: {
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      cudaPackages.cudatoolkit
      egl-wayland
      nvidia-vaapi-driver
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true;
    nvidiaSettings = true;

    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
