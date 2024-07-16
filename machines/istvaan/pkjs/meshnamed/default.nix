{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "meshnamed";
  version = "0.2.0";

  #src = ./meshname;

  src = fetchFromGitHub {
    owner = "zhoreeq";
    repo = "meshname";
    rev = "v${version}";
    sha256 = "sha256-fmJOGjOFlHqxNaewtJg3jR+ol8p/zY6RBYeNsxLy6VE=";
  };

  #src = ./meshname;

  vendorHash = "sha256-kiNxB2R3Z6Z/Resr3r4jKCImVhyoOY55dEiV+JRUjDk=";

  subPackages = ["cmd/meshnamed"];

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "Doomsday DNS";
    homepage = "https://github.com/zhoreeq/meshname";
    license = with licenses; [mit];
    maintainers = with maintainers; [DomesticMoth];
  };
}
