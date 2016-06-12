{ nixpkgs
, declInput 
, githubPulls
}:

with {
  inherit (import <nixpkgs/lib/attrsets.nix>) mapAttrs listToAttrs nameValuePair;
  inherit (import <nixpkgs/lib/debug.nix>) traceVal;
};

let
  pkgs = import nixpkgs {};
  
  concatWithSpace = s1: s2: if s2 == "" then s1 else s1 + " " + s2;

  gitBranchSpec = name: url: pull: {
    enabled = 1;
    hidden = false;
    description = "${name}: ${pull.title}";
    nixexprinput = "src";
    nixexprpath = "release.nix";
    checkinterval = 90;
    schedulingshares = 100;
    enableemail = true;
    emailoverride = "";
    keepnr = 3;
    inputs = {
      src = {
        type = "git";
        value = concatWithSpace url pull.head.sha;
        emailresponsible = true;
      };
      nixpkgs = {
        type = "git";
        value = "git://github.com/NixOS/nixpkgs.git release-16.03";
        emailresponsible = false;
      };
    };
  };

  teethBranch = gitBranchSpec "teeth" "git://github.com/expipiplus1/teeth.git";

  masterSpec = teethBranch {title = "master"; head.sha = "";};

  pulls = listToAttrs (map (v: nameValuePair v.title v)
                      (builtins.fromJSON githubPulls));

  pullSpecs = mapAttrs (n: v: teethBranch v) pulls;

  genSpec = pkgs.writeText "spec.conf" (builtins.toJSON (pullSpecs // masterSpec));

in {
  jobsets = genSpec;
}

