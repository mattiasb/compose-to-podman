#!/bin/bash

# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2022, Mattias Bengtsson <mattias.jc.bengtsson@gmail.com>

yaml2json "${1}" \
    | jq -r '.volumes
            | keys[]
            | "podman volume create " + . + " 2>/dev/null || true"
            '
yaml2json "${1}" \
    | jq -r '.services
            | values[]
            | { name: .container_name
              , restart
              , cpus
              , "add-host": ( .extra_hosts
                            | join("\" --add-host \"")
                            )
              , env:        ( .environment
                            | to_entries
                            | map(.key + "=" + .value)
                            | join("\" --env \"")
                            )
              , label:      ( .labels
                            | to_entries
                            | map(.key + "=" + .value)
                            | join("\" --label \"")
                            )
              , publish:    ( .ports
                            | join("\" --publish \"")
                            )
              , volume:     ( .volumes
                            | join("\" --volume \"")
                            )
              , image
              }
            | to_entries
            | map( if .key == "image" then .value
                   else ( "--"
                        + .key
                        + " \""
                        + .value
                        + "\" \\\n                       "
                        )
                   end
                 )
            | "podman container create " + join(" ")
            '
