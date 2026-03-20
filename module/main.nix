{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.nyx.services.omnisearch;

  OmniSearchRepackaged = inputs.omnisearch.packages.${pkgs.system}.omnisearchWith {
    templates = cfg.templates;
    static = cfg.static;
    config = cfg.configFile;
  };
in {
  # use myOmni

  config = mkIf cfg.enable {
    # Technically not needed but i am not 100% sure so i ll leave it in
    environment.systemPackages = [OmniSearchRepackaged];

    # Create a dedicated user and group and home
    users.users.omnisearch = {
      isSystemUser = true;
      group = "omnisearch";
      home = cfg.workDir;
      createHome = true; 
      description = "OmniSearch service user";
      shell = pkgs.bash;
    };

    users.groups.omnisearch = {};

    systemd.services.omnisearch = {
      description = "OmniSearch C metasearch engine";
      wants = ["network.target"];
      after = ["network.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${OmniSearchRepackaged}/bin/omnisearch";
        Restart = "on-failure";
        WorkingDirectory = "${cfg.workDir}"; 
        User = "omnisearch"; 
        Group = "omnisearch"; 
        # make this directory the "home" for the service user
        Environment = [
          "LD_LIBRARY_PATH=${OmniSearchRepackaged}/lib"
          "HOME=${cfg.workDir}"
        ];
      };

      wantedBy = ["multi-user.target"];
    };
  };
}
