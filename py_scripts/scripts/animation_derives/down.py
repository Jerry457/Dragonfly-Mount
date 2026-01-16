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
    wilson_animation_name="idle_loop",
    dragonfly_animation_name="idle",
    output_animation_name="idle_loop_down",
    split_front_back=True,
    animation_length_align=1,
    dragonfly_animation_range=[None, None],
    dragonfly_animation_repeat=1,
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

    dragonfly_idle = get_animation(dragonfly_anim, dragonfly_animation_name)

    if dragonfly_animation_repeat > 1:
        dragonfly_animations = []
        for i in range(dragonfly_animation_repeat):
            dragonfly_animations.append(deepcopy(dragonfly_idle))  # type: ignore
        dragonfly_idle = joint_animations(
            dragonfly_animations, dragonfly_animation_name
        )

    anim_range = dragonfly_animation_range
    if anim_range[0] is not None and anim_range[1] is not None:
        dragonfly_idle["frames"] = dragonfly_idle["frames"][  # type: ignore
            anim_range[0] : anim_range[1]
        ]
    elif anim_range[0] is not None:
        dragonfly_idle["frames"] = dragonfly_idle["frames"][anim_range[0] :]  # type: ignore
    elif anim_range[1] is not None:
        dragonfly_idle["frames"] = dragonfly_idle["frames"][: anim_range[1]]  # type: ignore

    if split_front_back:
        front, back = split_wilson_down_animation(wilson_animation)

        dragonfly_idle = apply_follow_symbol(
            dragonfly_idle,
            front,
            params={
                "follow_symbol": "dragonfly_head",
                "follow_num": r"\d+",
                "follow_all_match": False,
                "local_x": DOWN_DIR_X_OFFSET,
                "local_y": DOWN_DIR_Y_OFFSET,
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
                "alignment": animation_length_align,
                "interpolate": True,
            },
        )

    dragonfly_idle["name"] = output_animation_name  # type: ignore
    save_animation(dragonfly_idle, f"target/{output_animation_name}.json")


# ================= catch

derive_from_dragonfly_template(
    wilson_animation_name="catch_pre",
    dragonfly_animation_name="idle",
    output_animation_name="catch_pre",
    dragonfly_animation_range=[None, 12],
)

derive_from_dragonfly_template(
    wilson_animation_name="catch",
    dragonfly_animation_name="idle",
    output_animation_name="catch",
    dragonfly_animation_range=[12, None],
)

# ================= coach

derive_from_dragonfly_template(
    wilson_animation_name="coach",
    dragonfly_animation_name="idle",
    output_animation_name="coach",
    dragonfly_animation_repeat=2,
)

# ================= cointoss

derive_from_dragonfly_template(
    wilson_animation_name="cointoss",
    dragonfly_animation_name="idle",
    output_animation_name="cointoss",
    dragonfly_animation_repeat=2,
    dragonfly_animation_range=[4, None],
)

derive_from_dragonfly_template(
    wilson_animation_name="cointoss_pre",
    dragonfly_animation_name="idle",
    output_animation_name="cointoss_pre",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="cointoss_lag",
    dragonfly_animation_name="idle",
    output_animation_name="cointoss_lag",
    dragonfly_animation_range=[2, 4],
    animation_length_align=2,
)

# ================= dart

derive_from_dragonfly_template(
    wilson_animation_name="dart_pre_downside",
    dragonfly_animation_name="idle",
    output_animation_name="dart_pre_downside",
    dragonfly_animation_range=[0, 17],
)

derive_from_dragonfly_template(
    wilson_animation_name="dart_lag_downside",
    dragonfly_animation_name="idle",
    output_animation_name="dart_lag_downside",
    dragonfly_animation_range=[17, 20],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="dart_downside",
    dragonfly_animation_name="idle",
    output_animation_name="dart_downside",
    dragonfly_animation_range=[20, None],
)
