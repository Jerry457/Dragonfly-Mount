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
dragonfly_anim = load_anim("assets/dragonfly.json")


def derive_from_dragonfly_template(
    wilson_animation_name="walk_loop_side",
    dragonfly_animation_name="idle_side",
    output_animation_name="idle_side",
    split_front_back=True,
    animation_length_align=1,
    dragonfly_animation_range=[None, None],
):
    wilson_animation = get_animation(wilsonbeefalo_anim, wilson_animation_name)

    wilson_animation = apply_anti_follow_symbol(
        wilson_animation,
        {
            "anti_symbol": "beefalo_headbase",
            "follow_num": "",
            "maintain_scale": True,
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
                # # 固定手不要上下浮动
                # if element["frameNum"] == 18:
                #     element["ty"] = hand_18_ty or element["ty"]
                #     hand_18_ty = element["ty"]
                # elif element["frameNum"] == 19:
                #     element["ty"] = hand_19_ty or element["ty"]
                #     hand_19_ty = element["ty"]
                pass

    dragonfly_idle = get_animation(dragonfly_anim, dragonfly_animation_name)

    range = dragonfly_animation_range
    if range[0] is not None and range[1] is not None:
        dragonfly_idle["frames"] = dragonfly_idle["frames"][range[0] : range[1]]  # type: ignore
    elif range[0] is not None:
        dragonfly_idle["frames"] = dragonfly_idle["frames"][range[0] :]  # type: ignore
    elif range[1] is not None:
        dragonfly_idle["frames"] = dragonfly_idle["frames"][: range[1]]  # type: ignore

    if split_front_back:
        front, back = split_wilson_down_animation(wilson_animation)

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
                "alignment": animation_length_align,
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
                "alignment": animation_length_align,
                "interpolate": True,
            },
        )
    else:
        dragonfly_idle = apply_follow_symbol(
            dragonfly_idle,
            wilson_animation,
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
                "alignment": animation_length_align,
                "interpolate": True,
            },
        )

    dragonfly_idle["name"] = output_animation_name  # type: ignore
    save_animation(dragonfly_idle, f"target/{output_animation_name}.json")


# ================= dart

derive_from_dragonfly_template(
    wilson_animation_name="dart_pre_side",
    dragonfly_animation_name="idle_side",
    output_animation_name="dart_pre_side",
    dragonfly_animation_range=[0, 17],
)

derive_from_dragonfly_template(
    wilson_animation_name="dart_lag_side",
    dragonfly_animation_name="idle_side",
    output_animation_name="dart_lag_side",
    dragonfly_animation_range=[17, 20],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="dart_side",
    dragonfly_animation_name="idle_side",
    output_animation_name="dart_side",
    dragonfly_animation_range=[20, None],
)
