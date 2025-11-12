{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Build tools
    cmake
    gnumake
    python3

    # ARM toolchain for RP2040 and RP2350 (ARM cores)
    gcc-arm-embedded
    picotool

    # RISC-V toolchain for RP2350 RISC-V
    pkgsCross.riscv32-embedded.buildPackages.gcc
  ];

  shellHook = ''
    #export PICO_SDK_PATH="$(cd ../../pico-sdk/; pwd)"

    # Create a temporary bin directory for aliasing the RISC-V compiler
    TEMP_BIN_DIR=$(mktemp -d)

    # Create symlink so pico-sdk can find the compiler with the name it expects
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-gcc \
          $TEMP_BIN_DIR/riscv32-unknown-elf-gcc
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-g++ \
          $TEMP_BIN_DIR/riscv32-unknown-elf-g++
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-objcopy \
          $TEMP_BIN_DIR/riscv32-unknown-elf-objcopy
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-objdump \
          $TEMP_BIN_DIR/riscv32-unknown-elf-objdump
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-ar \
          $TEMP_BIN_DIR/riscv32-unknown-elf-ar
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-as \
          $TEMP_BIN_DIR/riscv32-unknown-elf-as
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-ld \
          $TEMP_BIN_DIR/riscv32-unknown-elf-ld
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-size \
          $TEMP_BIN_DIR/riscv32-unknown-elf-size
    ln -s ${pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-nm \
          $TEMP_BIN_DIR/riscv32-unknown-elf-nm

    # Add temp bin to PATH first
    export PATH="$TEMP_BIN_DIR:$PATH"

    # Tell CMake where to find the RISC-V compiler
    export PICO_TOOLCHAIN_PATH="$TEMP_BIN_DIR"

    # Cleanup on exit
    trap "rm -rf $TEMP_BIN_DIR" EXIT

    echo "Development environment ready!"
    # echo "PICO_SDK_PATH=$PICO_SDK_PATH"
    echo "RISC-V toolchain: $(which riscv32-unknown-elf-gcc || echo 'not found')"
    echo "ARM toolchain: $(which arm-none-eabi-gcc || echo 'not found')"
  '';
}
