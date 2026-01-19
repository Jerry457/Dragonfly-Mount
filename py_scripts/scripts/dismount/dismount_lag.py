import os
import sys

sys.path.append(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
)
from anti_follow_symbol import apply_anti_follow_symbol
from constant import *
from follow_symbol import apply_follow_symbol
from utils import *

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

dragonfly_takeoff = get_animation(dragonfly_anim, "land")
dragonfly_takeoff["frames"] = dragonfly_takeoff["frames"][-4:]

dragonfly_takeoff = apply_follow_symbol(
    dragonfly_takeoff,
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

reorder_animation(dragonfly_takeoff)

dragonfly_takeoff["name"] = "dismount_lag"

# for i in range(len(dragonfly_takeoff["frames"])):
#     frame = dragonfly_takeoff["frames"][i]
#     for j in range(len(frame["elements"])):
#         element = frame["elements"][j]
#         if str.lower(element["symbol"]) == "dragonfly_head":
#             element["frameNum"] = 0

save_animation(dragonfly_takeoff, f"target/dismount_lag.json")
