import os
import sys

sys.path.append(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
)
from anti_follow_symbol import apply_anti_follow_symbol
from constant import *
from follow_symbol import apply_follow_symbol
from utils import *

WILSON_ANIMATION_NAME = "walk_loop_side"
DRAGONFLY_ANIMATION_NAME = "walk_angry_pst_side"

OUTPUT_ANIMATION_NAME = "run_pst_side"


wilsonbeefalo_anim = load_anim("assets/wilsonbeefalo.json")


wilson_animation = get_animation(wilsonbeefalo_anim, WILSON_ANIMATION_NAME)


wilson_animation = apply_anti_follow_symbol(
    wilson_animation,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": False,
    },
)

wilson_animation = remove_beefalo_elements(wilson_animation)

hand_18_ty = None
hand_19_ty = None
for frame in wilson_animation["frames"]:  # type: ignore
    for element in frame["elements"]:
        if str.lower(element["symbol"]) == "swap_saddle":
            scaling_element(element, SIDE_DIR_SADDLE_SCALE_X, 1.0)
            element["tx"] = element["tx"] + SIDE_DIR_SADDLE_X_OFFSET
        elif str.lower(element["symbol"]) == "hand":
            # 固定手不要上下浮动
            if element["frameNum"] == 18:
                element["ty"] = hand_18_ty or element["ty"]
                hand_18_ty = element["ty"]
            elif element["frameNum"] == 19:
                element["ty"] = hand_19_ty or element["ty"]
                hand_19_ty = element["ty"]


front, back = split_wilson_side_animation(wilson_animation)

dragonfly_anim = load_anim("assets/dragonfly.json")

dragonfly_idle = get_animation(dragonfly_anim, DRAGONFLY_ANIMATION_NAME)

dragonfly_idle = apply_follow_symbol(
    dragonfly_idle,
    front,
    params={
        "follow_symbol": "dragonfly_head",
        "follow_num": r"\d+",
        "follow_all_match": False,
        "local_x": SIDE_DIR_X_OFFSET,
        "local_y": SIDE_DIR_Y_OFFSET,
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

dragonfly_idle = apply_follow_symbol(
    dragonfly_idle,
    back,
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

# 修改眼睛为非愤怒状态
for frame in dragonfly_idle["frames"]:  # type: ignore
    for element in frame["elements"]:
        if str.lower(element["symbol"]) == "dragonfly_head":
            num = element["frameNum"]
            if num == 17 or num == 18:
                element["frameNum"] = 1

dragonfly_idle["name"] = OUTPUT_ANIMATION_NAME  # type: ignore
save_animation(dragonfly_idle, f"target/{OUTPUT_ANIMATION_NAME}.json")
