{ pkgs, config, ... }: {
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      # cudaPackages.cudatoolkit
      egl-wayland
      intel-media-driver
      nvidia-vaapi-driver
      vpl-gpu-rt
    ];
  };

  services.xserver.videoDrivers = [
    "modesetting"  # Example for Intel iGPU; use "amdgpu" here instead if your iGPU is AMD
    "nvidia"
  ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true;
    nvidiaSettings = true;

    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Specify the Bus IDs for your GPUs; make sure they match your system's hardware
      # sudo lshw -c display
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
