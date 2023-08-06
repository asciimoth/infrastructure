# Infrastructure config by ASCIIMoth
#
# To the extent possible under law, the person who associated CC0 with
# this work has waived all copyright and related or neighboring rights
# to it.
#
# You should have received a copy of the CC0 legalcode along with this
# work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
{
  ConfigRoot = "/etc/infrastructure";
  MainUser = "moth";
  Editor = "micro";
  Email = "ascii@moth.contact";
  Nicknames = {
    Full = "ASCII Moth";
    Lower = "asciimoth";
  };
}
#let
#  ConfigRoot = "/etc/infrastructure";
#  MainUser = "moth";
#  Editor = "micro";
#in {
#  inherit
#    MainUser
#    ConfigRoot
#    Editor
#    ;
#}

