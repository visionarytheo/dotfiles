#!/usr/bin/env bash

export LD_PRELOAD=$LD_PRELOAD:/usr/lib/libgamemode.so

exec steam "$@"
