import os
import sys

sys.path.append(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
)
from anti_follow_symbol import apply_anti_follow_symbol
from constant import *
from follow_symbol import apply_follow_symbol
from utils import *

WILSON_ANIMATION_NAME = "useitem_dir_pre_upside"
DRAGONFLY_ANIMATION_NAME = "idle_upside"

OUTPUT_ANIMATION_NAME = "useitem_pre_upside"


wilsonbeefalo_anim = load_anim("assets/wilsonbeefalo.json")


wilson_animation = get_animation(wilsonbeefalo_anim, WILSON_ANIMATION_NAME)


wilson_animation = apply_anti_follow_symbol(
    wilson_animation,
    {
        "anti_symbol": "swap_saddle",
        "follow_num": "",
        "maintain_scale": True,
    },
)

wilson_animation = remove_beefalo_elements(wilson_animation)

dragonfly_anim = load_anim("assets/dragonfly.json")

dragonfly_idle = get_animation(dragonfly_anim, DRAGONFLY_ANIMATION_NAME)

dragonfly_idle["frames"] = dragonfly_idle["frames"][:14]

dragonfly_idle = apply_follow_symbol(
    dragonfly_idle,
    wilson_animation,
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

dragonfly_idle["name"] = OUTPUT_ANIMATION_NAME  # type: ignore
save_animation(dragonfly_idle, f"target/{OUTPUT_ANIMATION_NAME}.json")
