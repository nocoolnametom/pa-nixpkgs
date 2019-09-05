{ pkgs, buildPecl, php' }:

rec {
  pthreads = buildPecl rec {
    pname = "pthreads";
    version = "3.2.0-dev";

    src = pkgs.fetchFromGitHub {
      owner = "krakjoe";
      repo = "pthreads";
      rev = "4d1c2483ceb459ea4284db4eb06646d5715e7154";
      sha256 = "07kdxypy0bgggrfav2h1ccbv67lllbvpa3s3zsaqci0gq4fyi830";
    };

    buildInputs = with pkgs; [ pcre2.dev ];
  };

  pinba = buildPecl rec {
    version = "1.1.2-dev";
    pname = "pinba";

    src = pkgs.fetchFromGitHub {
      owner = "tony2001";
      repo = "pinba_extension";
      rev = "edbc313f1b4fb8407bf7d5acf63fbb0359c7fb2e";
      sha256 = "02sljqm6griw8ccqavl23f7w1hp2zflcv24lpf00k6pyrn9cwx80";
    };
  };
}
