#!/bin/sh

lcm-gen -j ../3dfls/lcmtypes/hauv_didson_t.lcm

javac -cp /usr/local/share/java/lcm.jar hauv/*.java

jar cf types.jar hauv/*.class