#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 5 ]; then
  echo "usage: $0 cheetah|salon SOURCE_DIRECTORY OUTPUT_DIRECTORY VERSION_CODE VERSION_NAME" >&2
  exit 2
fi

game_name="$1"
source_directory=$(cd "$2" && pwd)
output_directory="$3"
version_code="$4"
version_name="$5"

case "$version_code" in
  ''|*[!0-9]*)
    echo "version code must be a positive integer" >&2
    exit 2
    ;;
esac

if [ "$version_code" -lt 1 ] || [ "$version_code" -gt 2100000000 ]; then
  echo "version code must be between 1 and 2100000000" >&2
  exit 2
fi

case "$version_name" in
  ''|*[!A-Za-z0-9._+-]*)
    echo "version name may contain only letters, digits, dot, underscore, plus, and hyphen" >&2
    exit 2
    ;;
esac

required_signing_variables=(
  ANDROID_UPLOAD_KEYSTORE_PATH
  ANDROID_UPLOAD_KEYSTORE_PASSWORD
  ANDROID_UPLOAD_KEY_ALIAS
  ANDROID_UPLOAD_KEY_PASSWORD
)

for variable_name in "${required_signing_variables[@]}"; do
  if [ -z "${!variable_name:-}" ]; then
    echo "$variable_name is required" >&2
    exit 2
  fi
done

mkdir -p "$output_directory"
output_directory=$(cd "$output_directory" && pwd)

case "$game_name" in
  cheetah)
    love_android_commit=4c65fff4f8b38693aca5d91bc06f254f86a97adf
    build_directory=$(mktemp -d)
    trap 'rm -rf "$build_directory"' EXIT

    android_directory="$build_directory/love-android"
    game_archive="$build_directory/cheetah.love"

    git init --quiet "$android_directory"
    git -C "$android_directory" remote add origin https://github.com/love2d/love-android.git
    git -C "$android_directory" fetch --depth 1 origin "$love_android_commit"
    git -C "$android_directory" checkout --quiet --detach FETCH_HEAD
    git -C "$android_directory" submodule update --init --recursive --depth 1

    (
      cd "$source_directory"
      zip -9 -q -r "$game_archive" . \
        -x '.git/*' '.github/*' 'dist/*' 'README.md'
    )

    mkdir -p "$android_directory/app/src/embed/assets"
    cp "$game_archive" "$android_directory/app/src/embed/assets/game.love"

    sed -i '/^app.name_byte_array=/d' "$android_directory/gradle.properties"
    sed -i 's/^#app.name=.*/app.name=You Are a Cheetah/' "$android_directory/gradle.properties"
    sed -i 's/^app.application_id=.*/app.application_id=org.isomorphisms.cheetah/' "$android_directory/gradle.properties"
    sed -i "s/^app.version_code=.*/app.version_code=$version_code/" "$android_directory/gradle.properties"
    sed -i "s/^app.version_name=.*/app.version_name=$version_name/" "$android_directory/gradle.properties"
    sed -i 's/compileSdk = 35/compileSdk = 36/' "$android_directory/app/build.gradle"
    sed -i 's/targetSdk 35/targetSdk 36/' "$android_directory/app/build.gradle"

    cat >> "$android_directory/app/build.gradle" <<'GRADLE'

android {
    signingConfigs {
        playUpload {
            storeFile file(System.getenv("ANDROID_UPLOAD_KEYSTORE_PATH"))
            storePassword System.getenv("ANDROID_UPLOAD_KEYSTORE_PASSWORD")
            keyAlias System.getenv("ANDROID_UPLOAD_KEY_ALIAS")
            keyPassword System.getenv("ANDROID_UPLOAD_KEY_PASSWORD")
        }
    }
    buildTypes.release.signingConfig signingConfigs.playUpload
}
GRADLE

    "$android_directory/gradlew" \
      --project-dir "$android_directory" \
      --no-daemon \
      bundleEmbedNoRecordRelease

    bundle_path=$(find "$android_directory/app/build/outputs/bundle" -type f -name '*.aab' -print -quit)
    if [ -z "$bundle_path" ]; then
      echo "LÖVE Android build did not produce an app bundle" >&2
      exit 1
    fi
    cp "$bundle_path" "$output_directory/you-are-a-cheetah.aab"
    ;;

  salon)
    if [ "$ANDROID_UPLOAD_KEYSTORE_PASSWORD" != "$ANDROID_UPLOAD_KEY_PASSWORD" ]; then
      echo "Godot requires the upload key and keystore passwords to match" >&2
      exit 2
    fi

    preset_path="$source_directory/export_presets.cfg"
    sed -i 's/^gradle_build\/use_gradle_build=.*/gradle_build\/use_gradle_build=true/' "$preset_path"
    sed -i 's/^gradle_build\/export_format=.*/gradle_build\/export_format=1/' "$preset_path"
    sed -i 's/^package\/unique_name=.*/package\/unique_name="org.isomorphisms.dresstheunicorn"/' "$preset_path"
    sed -i "s/^version\/code=.*/version\/code=$version_code/" "$preset_path"
    sed -i "s/^version\/name=.*/version\/name=\"$version_name\"/" "$preset_path"

    if grep -q '^gradle_build/target_sdk=' "$preset_path"; then
      sed -i 's/^gradle_build\/target_sdk=.*/gradle_build\/target_sdk="36"/' "$preset_path"
    else
      sed -i '/^gradle_build\/export_format=/a gradle_build/target_sdk="36"' "$preset_path"
    fi

    export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$ANDROID_UPLOAD_KEYSTORE_PATH"
    export GODOT_ANDROID_KEYSTORE_RELEASE_USER="$ANDROID_UPLOAD_KEY_ALIAS"
    export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$ANDROID_UPLOAD_KEY_PASSWORD"

    godot --headless --path "$source_directory" --editor --quit
    godot --headless --path "$source_directory" --install-android-build-template --editor --quit
    godot --headless --path "$source_directory" \
      --export-release Android "$output_directory/dress-the-unicorn.aab"
    test -s "$output_directory/dress-the-unicorn.aab"
    ;;

  *)
    echo "unknown game: $game_name" >&2
    exit 2
    ;;
esac
