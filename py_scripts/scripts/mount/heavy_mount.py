import os
import sys

sys.path.append(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
)
from anti_follow_symbol import apply_anti_follow_symbol
from constant import *
from follow_symbol import apply_follow_symbol
from utils import *

LAND_SEP_IDX = 4

wilsonbeefalo_anim = load_anim("assets/wilsonbeefalo.json")
dragonfly_anim = load_anim("assets/dragonfly_land.json")

wilson_idle = get_animation(wilsonbeefalo_anim, "idle_loop")
wilson_idle = apply_anti_follow_symbol(
    wilson_idle,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": True,
    },
)
wilson_idle = remove_beefalo_elements(wilson_idle)
for frame in wilson_idle["frames"]:
    frame["elements"] = [
        element for element in frame["elements"] if (element["symbol"] == "swap_saddle")
    ]
    frame["elements"].sort(key=lambda x: x["zIndex"])
    for i in range(len(frame["elements"])):
        frame["elements"][i]["zIndex"] = i


dragonfly_land = get_animation(dragonfly_anim, "land")
dragonfly_land_1 = deepcopy(dragonfly_land)
dragonfly_land_1["frames"] = dragonfly_land_1["frames"][:LAND_SEP_IDX]

dragonfly_land_1 = apply_follow_symbol(
    dragonfly_land_1,
    wilson_idle,
    params={
        "follow_symbol": "dragonfly_head",
        "follow_num": r"\d+",
        "follow_all_match": False,
        "local_x": DOWN_DIR_X_OFFSET,
        "local_y": DOWN_DIR_Y_OFFSET,
        "local_scale_x": LOCAL_SCALE_X,
        "local_scale_y": LOCAL_SCALE_Y,
        "local_rotate": 0,
        "z_index_offset": 0,
        "inherit_pos_x": True,
        "inherit_pos_y": True,
        "inherit_scale": True,
        "inherit_rotation": True,
        "average_rotation": True,
        "alignment": 1,
        "interpolate": True,
    },
)

# ==========================================================================================

wilson_mount = get_animation(wilsonbeefalo_anim, "heavy_mount")
wilson_mount = apply_anti_follow_symbol(
    wilson_mount,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": True,
    },
)
wilson_mount = remove_beefalo_elements(wilson_mount)

fix_swap_saddle(wilson_mount)

wilson_mount_front, wilson_mount_back = split_wilson_down_animation(wilson_mount)

# front, back = split_wilson_animation(wilson_animation)

dragonfly_land_2 = deepcopy(dragonfly_land)
dragonfly_land_2["frames"] = dragonfly_land_2["frames"][LAND_SEP_IDX:]

# dragonfly_land_2["frames"] = relength_anim_frames(dragonfly_land_2["frames"], 12, True)

# dragonfly_takeoff = get_animation(dragonfly_anim, "takeoff")
# dragonfly_land_2 = joint_animations([dragonfly_land_2, dragonfly_takeoff], "takeoff")

dragonfly_land_2 = apply_follow_symbol(
    dragonfly_land_2,
    wilson_mount_back,
    params={
        "follow_symbol": "dragonfly_head",
        "follow_num": r"\d+",
        "follow_all_match": False,
        "local_x": DOWN_DIR_X_OFFSET,
        "local_y": DOWN_DIR_Y_OFFSET,
        "local_scale_x": LOCAL_SCALE_X,
        "local_scale_y": LOCAL_SCALE_Y,
        "local_rotate": 0,
        "z_index_offset": 0,
        "inherit_pos_x": True,
        "inherit_pos_y": True,
        "inherit_scale": True,
        "inherit_rotation": True,
        "average_rotation": True,
        "alignment": 1,
        "interpolate": True,
    },
)


def front_z_index_offset(idx):
    if idx > 24:
        return -1
    return 0


dragonfly_land_2 = apply_follow_symbol(
    dragonfly_land_2,
    wilson_mount_front,
    params={
        "follow_symbol": "dragonfly_head",
        "follow_num": r"\d+",
        "follow_all_match": False,
        "local_x": DOWN_DIR_X_OFFSET,
        "local_y": DOWN_DIR_Y_OFFSET,
        "local_scale_x": LOCAL_SCALE_X,
        "local_scale_y": LOCAL_SCALE_Y,
        "local_rotate": 0,
        "z_index_offset": front_z_index_offset,
        "inherit_pos_x": True,
        "inherit_pos_y": True,
        "inherit_scale": True,
        "inherit_rotation": True,
        "average_rotation": True,
        "alignment": 1,
        "interpolate": True,
    },
)

# ==========================================================================================

final = joint_animations([dragonfly_land_1, dragonfly_land_2], "heavy_mount")

# for i in range(len(final["frames"])):
#     frame = final["frames"][i]
#     for j in range(len(frame["elements"])):
#         element = frame["elements"][j]
#         if str.lower(element["symbol"]) == "dragonfly_head":
#             element["frameNum"] = 0

save_animation(final, f"target/heavy_mount.json")
