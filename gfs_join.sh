#!/bin/bash
 ccsd                             # Starts the CCS daemon
 cman_tool join                   # Joins the cluster
 fence_tool join                  # Joins the fence domain (starts fenced, must 
                                   #   start before any gfs stuff is used.)
 clvmd                            # Starts the CLVM daemon
 vgchange -aly                    # Activates LVM volumes (locally)
mount -t gfs /dev/vg/lvol /mnt   # Mounts a GFS file system
