#!/bin/bash

for x in vboxdrv vboxnetadp vboxnetflt vboxpci; do
    modprobe $x
done

