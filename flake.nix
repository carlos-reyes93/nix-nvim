{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem ["x86_64-linux"];
    extra_pkg_config = {
      allowUnfree = true;
    };
    # see :help nixCats.flake.outputs.overlays
    dependencyOverlays =
      /*
      (import ./overlays inputs) ++
      */
      (final: prev: {
        sonarlint-ls = prev.sonarlint-ls.override {
          mavenDepsHash = "sha256-Fk6JPMmzz7YnPWOdWKOXQ8z6bdYuXSgQdWBOaIlpd4A=";
        };
      })
      [
        (utils.standardPluginOverlay inputs)
      ];

    # see :help nixCats.flake.outputs.categories
    categoryDefinitions = {pkgs, ...}: {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          lazygit
          lua-language-server
          stylua
          nixd
          alejandra
          fd
          ripgrep
          lua54Packages.luacheck
          sonarlint-ls
          vtsls
          tailwindcss-language-server
        ];
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        debug = with pkgs.vimPlugins; [nvim-nio];
        general = with pkgs.vimPlugins; {
          always = [
            catppuccin-nvim
            lze
            lzextras
            plenary-nvim
            nvim-notify
            nvim-lspconfig
          ];
          moveToOptional = with pkgs.vimPlugins; [
            Navigator-nvim
            snacks-nvim
          ];
          extra = [
            oil-nvim
            nvim-web-devicons
          ];
        };
        ui = with pkgs.vimPlugins; [
          lualine-nvim
          lualine-lsp-progress
        ];
      };

      optionalPlugins = {
        general = {
          blink = with pkgs.vimPlugins; [
            luasnip
            cmp-cmdline
            blink-cmp
            blink-compat
            colorful-menu-nvim
          ];
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
          ];
          always = with pkgs.vimPlugins; [
            lazydev-nvim
            vim-sleuth
            mini-ai
            mini-icons
            mini-pairs
          ];
          extra = with pkgs.vimPlugins; [
            fidget-nvim
            vim-startuptime
            which-key-nvim
            indent-blankline-nvim
            gitsigns-nvim
          ];
        };

        debug = with pkgs.vimPlugins; {
          default = [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
        };
        lint = with pkgs.vimPlugins; [
          nvim-lint
        ];
        format = with pkgs.vimPlugins; [
          conform-nvim
        ];
        markdown = with pkgs.vimPlugins; [markdown-preview-nvim];
      };

      sharedLibraries = {
        general = [];
      };
    };

    packageDefinitions = {
      nvim = {pkgs, ...}: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          hosts.python3.enable = false;
          hosts.node.enable = false;
          hosts.ruby.enable = false;
          hosts.perl.enable = false;
          neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
        };
        categories = {
          general = true;
          ui = true;
          markdown = true;
          lint = true;
          format = true;
          lspDebugMode = false;
          colorscheme = "catppuccin";
        };
        extra = {
          nixdExtras = {
            nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      };

      regularCats = {pkgs,...}: {
        settings = {
          wrapRc = false;
          aliases = ["testNvim"];
          configDirName = "nvim";
          neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
        };
        categories = {
          general = true;
          ui = true;
          markdown = true;
          lint = true;
          format = true;
          lspDebugMode = false;
          colorscheme = "catppuccin";
        };
      };
    };

    # see :help nixCats.flake.outputs.packageDefinitions
    defaultPackageName = "nvim";
  in
    # see :help nixCats.flake.outputs.exports
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      # this is just for using utils such as pkgs.mkShell
      # The one used to build neovim is resolved inside the builder
      # and is passed to our categoryDefinitions and packageDefinitions
      pkgs = import nixpkgs {inherit system;};
    in {
      # these outputs will be wrapped with ${system} by utils.eachSystem

      # this will make a package out of each of the packageDefinitions defined above
      # and set the default package to the one passed in here.
      packages = utils.mkAllWithDefault defaultPackage;

      # choose your package for devShell
      # and add whatever else you want in it.
      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      # we also export a nixos module to allow reconfiguration from configuration.nix
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      # these outputs will be NOT wrapped with ${system}

      # this will make an overlay out of each of the packageDefinitions defined above
      # and set the default overlay to the one named here.
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}
