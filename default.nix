{
  pkgs ? import <nixpkgs> {},
  nixCats ?
    builtins.fetchGit {
      url = "https://github.com/BirdeeHub/nixCats-nvim";
    },
  ...
}: let
  utils = import nixCats;
  luaPath = ./.;

  # see :help nixCats.flake.outputs.categories
  categoryDefinitions = {
    pkgs,
    settings,
    categories,
    extra,
    name,
    mkPlugin,
    ...
  } @ packageDef: {
    lspsAndRuntimeDeps = {
      general = with pkgs; [
        lazygit
        lua-language-server
        stylua
        nixd
        alejandra
        fd
        ripgrep
      ];
    };

    # This is for plugins that will load at startup without using packadd:
    startupPlugins = {
      general = with pkgs.vimPlugins; [
        snacks-nvim
        catppuccin-nvim
        vim-sleuth
        mini-ai
        mini-icons
        mini-pairs
        nvim-lspconfig
        vim-startuptime
        blink-cmp
        nvim-treesitter.withAllGrammars
        lualine-nvim
        lualine-lsp-progress
        gitsigns-nvim
        which-key-nvim
        nvim-lint
        conform-nvim
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
        oil-nvim
      ];
    };

    optionalPlugins = {
      general = with pkgs.vimPlugins; [
        lazydev-nvim
      ];
    };

    sharedLibraries = {
      general = with pkgs; [];
    };
  };

  # see :help nixCats.flake.outputs.packageDefinitions
  packageDefinitions = {
    nvim = {
      pkgs,
      name,
      mkPlugin,
      ...
    }: {
      settings = {
        suffix-path = true;
        suffix-LD = true;
        hosts.python3.enable = false;
        hosts.node.enable = false;
        hosts.ruby.enable = false;
        hosts.perl.enable = false;
      };
      categories = {
        general = true;
      };
      # anything else to pass and grab in lua with `nixCats.extra`
      extra = {};
    };

    regularCats = {pkgs, ...} @ misc: {
      settings = {
        wrapRc = false;
      };
      categories = {
        general = true;
      };
    };
  };

  # We will build the one named nvim here and export that one.
  defaultPackageName = "nvim";
  # return our package!
in
  utils.baseBuilder luaPath {inherit pkgs;} categoryDefinitions packageDefinitions defaultPackageName
