{ nixpkgs, declInput }: 

let 
  pkgs = import nixpkgs {}; 

in {
  jobsets = pkgs.runCommand "spec.json" {} ''
    cat <<EOF
    ${builtins.toXML declInput}
    EOF

    cat > $out <<EOF
    {
      "teeth": {
        "enabled": 1,
        "hidden": false,
        "description": "teeth description",
        "nixexprinput": "src",
        "nixexprpath": "release.nix",
        "checkinterval": 60,
        "schedulingshares": 100,
        "enableemail": true,
        "emailoverride": "",
        "keepnr": 3,
        "inputs": {
            "src": { "type": "git", "value": "git://github.com/expipiplus1/teeth.git hydra", "emailresponsible": true },
            "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs.git release-16.03", "emailresponsible": false }
        }
      }
    }

    EOF
  '';
}

