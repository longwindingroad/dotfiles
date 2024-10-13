{
  description = "Long flakes";

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs =
    inputs @ { self
    , nixpkgs
    , darwin
    , home-manager
    , ...
    }:
    let
      username = "longnguyen23";
      useremail = "long.nguyen23@onemount.com";
      system = "x86_64-darwin"; # aarch64-darwin or x86_64-darwin
      hostname = "mac";

      specialArgs =
        inputs
        // {
          inherit username useremail hostname;
        };
    in
    {
      darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
        inherit system;
        # inherit specialArgs;
        modules = [
          ./modules/core
          ./hosts/mac

          # home manager
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ./modules/home-manager;
          }
        ];
      };

      # nix code formatter
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
