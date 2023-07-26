#!/bin/bash

# Infrastructure config by ASCIIMoth
#
# To the extent possible under law, the person who associated CC0 with
# this work has waived all copyright and related or neighboring rights
# to it.
#
# You should have received a copy of the CC0 legalcode along with this
# work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

echo "Starting with user <$(whoami)>"

stringContain() { [ -z "${2##*$1*}" ]; }

function mute_speakers {
    #echo "Muting speakers"
    SINKS_RAW=$(pactl list sinks)
    SINK_NOM="NONVALIDNOM"
    BUILT_IN_SINK_NOM="NONVALIDNOM"
    tab=$(printf '\t')
    while IFS= read -r SINK; do
       #echo "Sink: $SINK"
       if [[ $SINK =~ $tab ]]; then
         if [[ $SINK =~ "Built-in" ]]; then
           BUILT_IN_SINK_NOM=$SINK_NOM
         fi
         if [[ $SINK =~ "type: Speaker" ]]; then
           BUILT_IN_SINK_NOM=$SINK_NOM
         fi        
         if [[ $SINK =~ "Active Port:" ]]; then
            echo "Active sink: $SINK_NOM; BSN: $BUILT_IN_SINK_NOM; Sink: $SINK"
            if echo $SINK | grep -iqF "speaker"; then
              echo "Sink $SINK_NOM is built-in speaker and currently active"
              if [ $BUILT_IN_SINK_NOM != "NONVALIDNOM" ]; then
                echo "MUTE: $BUILT_IN_SINK_NOM"
                pactl -- set-sink-volume $BUILT_IN_SINK_NOM 0%
                #pactl -- set-sink-mute $BUILT_IN_SINK_NOM 1
              fi
            fi
         fi
       else
         N="${SINK//[!0-9]/}"
         echo "Sink: <$SINK> Nom: <$N>"
         if [[ ! -z "$N" ]]; then
            SINK_NOM=$N
            BUILT_IN_SINK_NOM="NONVALIDNOM"
            #echo $SINK_NOM
         fi
       fi
    done <<< "$SINKS_RAW" 
}

mute_speakers

echo "Started"

pactl subscribe | while read x event y type num; do
  if [ $type == 'sink' ]; then
    mute_speakers
  fi
done
