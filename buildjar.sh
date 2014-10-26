#!/bin/sh

# 'standard' hauv lcm types
lcm-gen -j ../3dfls/3dfls/lcmtypes/hauv_didson_t.lcm       # didson
lcm-gen -j ../3dfls/3dfls/lcmtypes/hauv_raw_ping_t.lcm     # 3dfls
lcm-gen -j ../3dfls/3dfls/lcmtypes/hauv_sonar_points_t.lcm # registered sonar returns

# occupancy grid mapping
lcm-gen -j ../ogmapper/lcmtypes/hauv_sonar_range_t.lcm     # single beam
lcm-gen -j ../ogmapper/lcmtypes/hauv_sonar_scan_t.lcm      # set/collection of beams (didson/3dfls)

# 
javac -cp /usr/local/share/java/lcm.jar hauv/*.java
jar cf types.jar hauv/*.class
