#!/bin/sh

lcm-gen -j ../3dfls/3dfls/lcmtypes/hauv_didson_t.lcm

lcm-gen -j ../3dfls/3dfls/lcmtypes/hauv_raw_ping_t.lcm

lcm-gen -j ../3dfls/3dfls/lcmtypes/hauv_sonar_points_t.lcm

javac -cp /usr/local/share/java/lcm.jar hauv/*.java

jar cf types.jar hauv/*.class
