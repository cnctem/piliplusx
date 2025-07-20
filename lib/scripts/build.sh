#!/bin/bash

build_time=$(date +%s)
commit_hash=$(git rev-parse HEAD)

cat <<EOL > lib/build_config.dart
class BuildConfig {
  static const int buildTime = $build_time;
  static const String commitHash = '$commit_hash';
}
EOL
