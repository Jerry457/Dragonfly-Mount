import os

os.chdir(os.path.dirname(os.path.abspath(__file__)))

from anti_follow_symbol import apply_anti_follow_symbol
from constant import *
from follow_symbol import apply_follow_symbol
from utils import *

wilsonbeefalo_anim = load_anim("assets/wilsonbeefalo.json")
dragonfly_anim = load_anim("assets/dragonfly.json")

# ================ down

wilson_down = get_animation(wilsonbeefalo_anim, "idle_loop")

wilson_down = apply_anti_follow_symbol(
    wilson_down,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": True,
    },
)

for frame in wilson_down["frames"]:  # type: ignore
    frame["elements"] = [
        element
        for element in frame["elements"]
        if str.lower(element["symbol"]) == "swap_saddle"
    ]
    frame["elements"][0]["zIndex"] = 0

wilson_down["frames"] = wilson_down["frames"][0:1]  # type: ignore

# ================ side

wilson_side = get_animation(wilsonbeefalo_anim, "walk_loop_side")

wilson_side = apply_anti_follow_symbol(
    wilson_side,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": True,
    },
)

for frame in wilson_side["frames"]:  # type: ignore
    frame["elements"] = [
        element
        for element in frame["elements"]
        if str.lower(element["symbol"]) == "swap_saddle"
    ]
    frame["elements"][0]["zIndex"] = 0
    scaling_element(frame["elements"][0], SIDE_DIR_SADDLE_SCALE_X, 1.0)
    frame["elements"][0]["tx"] = frame["elements"][0]["tx"] + SIDE_DIR_SADDLE_X_OFFSET

wilson_side["frames"] = wilson_side["frames"][0:1]  # type: ignore

# ================ up

wilson_up = get_animation(wilsonbeefalo_anim, "idle_loop_upside")

wilson_up = apply_anti_follow_symbol(
    wilson_up,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": True,
    },
)

for frame in wilson_up["frames"]:  # type: ignore
    frame["elements"] = [
        element
        for element in frame["elements"]
        if str.lower(element["symbol"]) == "swap_saddle"
    ]
    frame["elements"][0]["zIndex"] = 0

wilson_up["frames"] = wilson_up["frames"][0:1]  # type: ignore

# ================ follow


bank = dragonfly_anim["banks"][0]
bank["name"] = "dragonfly_mount"
for i, animation in enumerate(bank["animations"]):
    name = animation["name"]
    if name == "corpse" or name == "corpse_hit" or name == "death":
        continue
    if "_up" in name:
        # up
        bank["animations"][i] = apply_follow_symbol(
            animation,
            deepcopy(wilson_up),
            params={
                "follow_symbol": "dragonfly_head",
                "follow_num": r"\d+",
                "follow_all_match": False,
                "local_x": UP_DIR_X_OFFSET,
                "local_y": UP_DIR_Y_OFFSET,
                "local_scale_x": LOCAL_SCALE_X,
                "local_scale_y": LOCAL_SCALE_Y,
                "local_rotate": 0,
                "z_index_offset": -1,
                "inherit_pos_x": True,
                "inherit_pos_y": True,
                "inherit_scale": True,
                "inherit_rotation": True,
                "average_rotation": True,
                "alignment": 1,
                "interpolate": True,
            },
        )
    elif "_side" in name:
        bank["animations"][i] = apply_follow_symbol(
            animation,
            deepcopy(wilson_side),
            params={
                "follow_symbol": "dragonfly_head",
                "follow_num": r"\d+",
                "follow_all_match": False,
                "local_x": SIDE_DIR_X_OFFSET,
                "local_y": SIDE_DIR_Y_OFFSET,
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
    else:
        # down
        bank["animations"][i] = apply_follow_symbol(
            animation,
            deepcopy(wilson_down),
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


json.dump(dragonfly_anim, open("dragonfly_mount.json", "w"), indent=None)
