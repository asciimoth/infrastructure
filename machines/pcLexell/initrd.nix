# Infrastructure config by DomesticMoth
#
# To the extent possible under law, the person who associated CC0 with
# this work has waived all copyright and related or neighboring rights
# to it.
#
# You should have received a copy of the CC0 legalcode along with this
# work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  boot.initrd = {
    postDeviceCommands = let
      encrypted_key_b64 = (builtins.readFile ./encrypted_key.b64);
      gpg_key_b64 = "mDMEZLBs3xYJKwYBBAHaRw8BAQdAvQ1PVijYCri1r7qn9RPlLTycvOr9fLQPq8Ph5pN+1H60J0FTQ0lJIE1vdGggKF4wdzBeKSA8YXNjaWlAbW90aC5jb250YWN0PoiQBBMWCAA4FiEExchGWMz9fo5x3ukzrzrlT8OjXJ8FAmSwbN8CGwEFCwkIBwIGFQoJCAsCBBYCAwECHgECF4AACgkQrzrlT8OjXJ85bAEAr6+pe3ExhiCaPj9YJMsl4QPwu3Ni6o9hMQBIpffOEusBAJfYv2nUxUoHV1IXZeHpAKRmrsuD7ORlNfjDsfcoapoAuDMEZLBtFhYJKwYBBAHaRw8BAQdAmuoq5NgrBYZn6qXqchQOYexzEWS/1wrc/48N0uC+8VOI7wQYFggAIBYhBMXIRljM/X6Ocd7pM6865U/Do1yfBQJksG0WAhsCAIEJEK865U/Do1yfdiAEGRYIAB0WIQSCs1B4bnpeBAue0YS2czOfKVWMNQUCZLBtFgAKCRC2czOfKVWMNdfCAP4zvjZ1IjIbexFftopgkyUNgkZRNgYvIJMpnEw1vt0CrQEAva4DkaGUkFAR3BNh+ZpSXJrmOPv7oAoYpW5fiwtwqgLPBwEAv6KwvYvh/V8M9MtksVNsSTfuTOB+evTlJePr8ZwI9RkBALc0MQBvGQ4sX2UQOlNEJs5fT57we1W0dFaVux4BS2YBuDgEZLBtNxIKKwYBBAGXVQEFAQEHQGHOJSoGpSRuGCna5ogFq7dLgZax8+TVf5S4ue9h/ysRAwEIB4h4BBgWCAAgFiEExchGWMz9fo5x3ukzrzrlT8OjXJ8FAmSwbTcCGwwACgkQrzrlT8OjXJ8x7AD+N8b1rEGw0qIZN+Nq8fmQo4mpOAwoGS4gDBVTxFUmhpkBANhd9sJ/akLVfj9qYFpQqVe2z5/eQQSrRLbQUTv2OM8FuDMEZLBtXhYJKwYBBAHaRw8BAQdApj4HKiGXBF5qmc+iWwb6JW4rwKPRV75Vfs67UIm9GUWIeAQYFggAIBYhBMXIRljM/X6Ocd7pM6865U/Do1yfBQJksG1eAhsgAAoJEK865U/Do1yf/AAA/1mKVrWxdWg+Is0S9/ByUvCLGcOHZj825fABtQrNt9c0AP4nLBcBFCQ+CTWc8jhBerQyReyfu+sIF9g5OfPN1AtlDw==";
    in
      lib.mkBefore ''
        echo "${encrypted_key_b64}" | base64 -d > encrypted_key
        echo "${gpg_key_b64}" | base64 -d > gpg_key
      '';
    luks.devices."crypted" = {
      preLVM = lib.mkForce false;
      gpgCard = {
        encryptedPass = "/encrypted_key";
        publicKey = "/gpg_key";
      };
    };
  };
}
