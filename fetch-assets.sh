#!/usr/bin/env bash
# Downloads free (CC0 / public domain) assets for the Nightmare Manor game.
set -u
cd "$(dirname "$0")"
T=assets/textures
V=vendor
M=assets/models
mkdir -p "$T" "$V" "$M" assets/video

echo "== three.js r128 add-ons =="
BASE=https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js
for f in loaders/GLTFLoader.js postprocessing/EffectComposer.js postprocessing/RenderPass.js postprocessing/ShaderPass.js postprocessing/UnrealBloomPass.js postprocessing/FilmPass.js shaders/CopyShader.js shaders/LuminosityHighPassShader.js shaders/FilmShader.js shaders/VignetteShader.js shaders/RGBShiftShader.js; do
  curl -sfL "$BASE/$f" -o "$V/$(basename $f)" && echo "ok $f" || echo "FAIL $f"
done
curl -sfL https://cdn.jsdelivr.net/npm/three@0.128.0/build/three.min.js -o "$V/three.min.js" && echo "ok three.min.js"

echo "== animated model =="
curl -sfL https://raw.githubusercontent.com/mrdoob/three.js/r128/examples/models/gltf/Soldier.glb -o "$M/stalker.glb" && echo "ok stalker.glb"

echo "== Poly Haven CC0 textures =="
# slot:candidate1,candidate2,...  (first that exists wins)
SLOTS=(
  "wall:rough_plaster_brick_04,plastered_wall_02,painted_plaster_wall,plastered_wall"
  "stone:castle_brick_07,medieval_blocks_02,castle_brick_01,stone_wall"
  "floorwood:dark_wooden_planks,wood_floor_worn,old_wood_floor,wood_floor_deck"
  "concrete:concrete_floor_worn_001,concrete_floor_damaged_01,patterned_concrete_wall,concrete_wall_008"
  "tiles:dirty_tiles,square_tiles_03,white_tiles,tiles_01"
  "fabric:fabric_pattern_07,velour_velvet,fabric_pattern_05,denim_fabric"
  "warmwood:wood_floor,laminate_floor_02,herringbone_parquet,wood_planks"
  "rust:rusty_metal_02,rusty_metal_04,rust_coarse_01,metal_plate"
)
for s in "${SLOTS[@]}"; do
  slot=${s%%:*}; cands=${s#*:}
  done_slot=0
  IFS=',' read -ra arr <<< "$cands"
  for name in "${arr[@]}"; do
    url="https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/$name/${name}_diff_1k.jpg"
    if curl -sfL "$url" -o "$T/${slot}_diff.jpg"; then
      curl -sfL "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/$name/${name}_nor_gl_1k.jpg" -o "$T/${slot}_nor.jpg"
      curl -sfL "https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/$name/${name}_rough_1k.jpg" -o "$T/${slot}_rough.jpg"
      echo "ok $slot <- $name"; done_slot=1; break
    fi
  done
  [ $done_slot = 0 ] && echo "FAIL $slot"
done

echo "== Public-domain horror films (Wikimedia Commons) =="
for q in "Night of the Living Dead 1968" "Nosferatu 1922" "The Cabinet of Dr. Caligari" "House on Haunted Hill 1959"; do
  curl -sfG "https://commons.wikimedia.org/w/api.php" --data-urlencode "action=query" --data-urlencode "generator=search" \
    --data-urlencode "gsrsearch=$q filetype:video" --data-urlencode "gsrnamespace=6" --data-urlencode "gsrlimit=5" \
    --data-urlencode "prop=videoinfo" --data-urlencode "viprop=url|size|derivatives" --data-urlencode "format=json" \
    -A "NightmareManorGame/1.0" -o "assets/video/search_$(echo $q | tr ' .' '__').json" && echo "searched: $q"
done
echo DONE
