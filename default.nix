{ nixpkgs
, declInput 
, githubPulls
}:

let
  pkgs = import nixpkgs {};

  teethBranch = branch: {
    enabled = 1;
    hidden = false;
    description = "teeth ${branch} : " + githubPulls {};
    nixexprinput = "src";
    nixexprpath = "release.nix";
    checkinterval = 60;
    schedulingshares = 100;
    enableemail = true;
    emailoverride = "";
    keepnr = 3;
    inputs = {
      src = {
        type = "git";
        value = "git://github.com/expipiplus1/teeth.git ${branch}";
        emailresponsible = true;
      };
      nixpkgs = {
        type = "git";
        value = "git://github.com/NixOS/nixpkgs.git release-16.03";
        emailresponsible = false;
      };
    };
  };

  genSpec = pkgs.writeText "spec.conf" (builtins.toJSON rec {
    teeth = teethBranch "master";
    teeth-ghc8 = teethBranch "ghc8";
  });

in {
  jobsets = genSpec;
}

