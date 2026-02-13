{
  description = "arduino-pico-internal libpico build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              gcc-arm-embedded
              cmake
              python3
              git
            ];

            shellHook = ''
              echo -e "\e[1;34marduino-pico-internal build environment activated.\e[0m"
              echo -e "$(arm-none-eabi-g++ --version | head -n1)"
            '';
          };
        }
      );
    };
}
