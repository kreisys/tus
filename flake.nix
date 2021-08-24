{
  description = "TUS protocol for resumable file uploads via HTTP";

  inputs.utils.url = "github:kreisys/flake-utils";

  outputs = { self, nixpkgs, utils }: utils.lib.simpleFlake {
    inherit nixpkgs;
    systems = [ "x86_64-linux" "x86_64-darwin" ];

    overlay = final: prev: {
      swiplPacks = (prev.swiplPacks or { }) // {
        tus = with final; stdenv.mkDerivation {
          pname = "swipl-pack-tus";
          version = self.shortRev or "DIRTY";
          buildInputs = [ swiProlog ];
          src = self;

          installPhase = ''
            mkdir -p $out/share/swi-prolog/pack
            swipl \
              -g "pack_install('file://$PWD', [package_directory('$_'), silent(true), interactive(false)])." -t "halt." 2>&1 | \
	            grep -v 'qsave(strip_failed' | \
	            (! grep -e ERROR -e Warning)
          '';
        };
      };
    };

    packages = { swiplPacks }: {
      inherit swiplPacks;
      defaultPackage = swiplPacks.tus;
    };
  };
}
