{lib, ...}:
with lib; {
  options = {
    nyx.services.omnisearch = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the OmniSearch service.";
      };

      templates = mkOption {
        type = types.path;
        default = ../omnisearchTest/templates;
        description = "Path to the OmniSearch HTML templates.";
      };

      static = mkOption {
        type = types.path;
        default = ../omnisearchTest/static;
        description = "Path to the static assets (CSS, JS, images) for OmniSearch.";
      };

      configFile = mkOption {
        type = types.path;
        default = ../omnisearchTest/example-config.ini;
        description = "Path to the OmniSearch configuration file.";
      };

      workDir = mkOption {
        type = types.path;
        default = "/srv/omnisearch";
        description = "Working directory for OmniSearch (same directory as in the config ini).";
      };
    };
  };
}
