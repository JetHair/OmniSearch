# OmniSearch 

I really like bwaaa.monsters work for Omnisearch.

So why not make a moduel :3  

Feel free to use it but please check the [Official Repo](https://git.bwaaa.monster/omnisearch/)  

## Showcase 

Checkout [ALovelySearch](https://search.alovely.space/)

## Usage

I recommend not installing the Package directly even though it is possible.   

### Use the Module 

This is my recommended way: 

```nix
# flake.nix
{
  description = "Your flake";

  inputs = {
    ## Use whatever nixpkgs you have
    # nixpkgs.url = "git+https://git.alovely.space/Mirrors/nixpkgs.git?ref=nixos-unstable";
    # or official:
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # The rest of your inputs homemanager etc (none are required)....

    # add OmniSearch
    omnisearch = {
      url = "git+https://git.alovely.space/Nyx/OmniSearch.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    # Example: NixOS configuration
    nixosConfigurations.YOURCLIENT = nixpkgs.lib.nixosSystem {
      inherit system;

      # Pass inputs into the module system so omnisearch can access them
      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./configuration.nix

        # either here or later in your configuration directly
        inputs.omnisearch.nixosModules.default
      ];
    };
  };
}


``` 


```nix
# configuration.nix
{
  config,
  pkgs,
  # might not be needed if you import in your flake directly like in the example above
  # inputs,
  ...
}: {
  # Not required because it is already imported in the flake
  # imports = [
  #   inputs.omnisearch.nixosModules.omnisearch
  # ];

  # Enable the service
  nyx.services.omnisearch.enable = true;

  # Optional: override templates, static assets, or config file
  # Copy the original once either from the Flake repo or [Official Repo](https://git.bwaaa.monster/omnisearch/)

  nyx.services.omnisearch.templates = ./yourOmniseachInputs/templates;
  nyx.services.omnisearch.static = ./yourOmniseachInputs/static;
  nyx.services.omnisearch.configFile = ./yourOmniseachInputs/config.ini;
  # Note these files need to be tracked by git and an relative path.

  # rest of your configuration.nix:
  # ...
  # ...
  # ...
  # ...
}

``` 

