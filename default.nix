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

  # see :help nixCats.flake.outputs.packageDefinitions
  packageDefinitions = {
    nvim = {pkgs, ...}: {
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

    regularCats = {...}: {
      settings = {
        wrapRc = false;
        aliases = ["testNvim"];
        configDirName = "nvim";
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

  defaultPackageName = "nvim";
in
  utils.baseBuilder luaPath {inherit pkgs;} categoryDefinitions packageDefinitions defaultPackageName
