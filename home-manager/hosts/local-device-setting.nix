# Machine-specific device settings (managed locally via git skip-worktree)
# Override this file locally for device-specific configuration.
#
# Intel/AMD: no configuration needed, mesa is included automatically.
#
# NVIDIA: version and sha256 must match the driver installed on the system.
# The sha256 can be found in nixpkgs at the pinned flake.lock commit:
#   pkgs/os-specific/linux/nvidia-x11/default.nix
#
# Example for NVIDIA GPU:
#   targets.genericLinux.gpu.nvidia = {
#     enable = true;
#     version = "580.126.09";
#     sha256 = "sha256-...";
#   };
{ ... }: { }
