#!/usr/bin/env bash
# Usage: wol 00:11:22:33:44:55 192.168.1.255 9
BCAST="${2:-255.255.255.255}"
# perl-based, no root needed
wakeonlan "${MAC}"
