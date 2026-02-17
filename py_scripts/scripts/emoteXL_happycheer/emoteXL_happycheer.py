import os
import sys

sys.path.append(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
)
from anti_follow_symbol import apply_anti_follow_symbol
from constant import *
from follow_symbol import apply_follow_symbol
from utils import *

WILSON_ANIMATION_NAME = "emote_happycheer"
DRAGONFLY_ANIMATION_NAME = "emoteXL_happycheer"

OUTPUT_ANIMATION_NAME = "emoteXL_happycheer"

wilsonbeefalo_anim = load_anim("assets/wilsonbeefalo.json")


wilson_idle = get_animation(wilsonbeefalo_anim, "idle_loop")
wilson_idle = apply_anti_follow_symbol(
    wilson_idle,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": True,
    },
)

wilson_animation = get_animation(wilsonbeefalo_anim, WILSON_ANIMATION_NAME)

wilson_animation = apply_anti_follow_symbol(
    wilson_animation,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": True,
    },
)

wilson_animation = remove_beefalo_elements(wilson_animation)

fix_swap_saddle(wilson_animation, True, True, wilson_idle)

front, back = split_wilson_down_animation(wilson_animation)

dragonfly_anim = load_anim("assets/emote_cheer.json")

dragonfly_idle = get_animation(dragonfly_anim, DRAGONFLY_ANIMATION_NAME)

mult = 1.3 / 1.3


def local_x(element, idx):
    if idx < 1:
        return DOWN_DIR_X_OFFSET
    return -DOWN_DIR_X_OFFSET


def local_scale_x(element, idx):
    if idx < 1:
        return LOCAL_SCALE_X
    return -LOCAL_SCALE_X * mult


def local_y(element, idx):
    if idx < 1:
        return DOWN_DIR_Y_OFFSET
    return DOWN_DIR_Y_OFFSET


def local_scale_y(element, idx):
    if idx < 1:
        return LOCAL_SCALE_Y
    return LOCAL_SCALE_Y * mult


dragonfly_idle = apply_follow_symbol(
    dragonfly_idle,
    front,
    params={
        "follow_symbol": "dragonfly_head",
        "follow_num": r"\d+",
        "follow_all_match": False,
        "local_x": local_x,
        "local_y": local_y,
        "local_scale_x": local_scale_x,
        "local_scale_y": local_scale_y,
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

dragonfly_idle = apply_follow_symbol(
    dragonfly_idle,
    back,
    params={
        "follow_symbol": "dragonfly_head",
        "follow_num": r"\d+",
        "follow_all_match": False,
        "local_x": local_x,
        "local_y": local_y,
        "local_scale_x": local_scale_x,
        "local_scale_y": local_scale_y,
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


dragonfly_idle["name"] = OUTPUT_ANIMATION_NAME  # type: ignore
save_animation(dragonfly_idle, f"target/{OUTPUT_ANIMATION_NAME}.json")
