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

wilson_idle = get_animation(wilsonbeefalo_anim, "idle_loop")
wilson_idle = apply_anti_follow_symbol(
    wilson_idle,
    {
        "anti_symbol": "beefalo_headbase",
        "follow_num": "",
        "maintain_scale": True,
    },
)


def derive_from_dragonfly_template(
    wilson_animation_name="idle_loop",
    dragonfly_animation_name="idle",
    output_animation_name="idle_loop_down",
    split_front_back=True,
    animation_length_align=1,
    dragonfly_animation_range=[None, None],
    dragonfly_animation_repeat=1,
    fix_swap_saddle_scale=True,
    fix_swap_saddle_pos=True,
    use_default_saddle_fix=True,
    pre_init_wilson_animation=None,
):
    wilson_animation = get_animation(wilsonbeefalo_anim, wilson_animation_name)

    if pre_init_wilson_animation:
        pre_init_wilson_animation(wilson_animation)

    wilson_animation = apply_anti_follow_symbol(
        wilson_animation,
        {
            "anti_symbol": "beefalo_headbase",
            "follow_num": "",
            "maintain_scale": True,
        },
    )

    wilson_animation = remove_beefalo_elements(wilson_animation)

    if use_default_saddle_fix:
        fix_swap_saddle(
            wilson_animation, fix_swap_saddle_scale, fix_swap_saddle_pos, wilson_idle
        )
    else:
        fix_swap_saddle(wilson_animation, fix_swap_saddle_scale, fix_swap_saddle_pos)

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

    reorder_animation(dragonfly_idle)
    dragonfly_idle["name"] = output_animation_name  # type: ignore
    save_animation(dragonfly_idle, f"target/{output_animation_name}.json")


for i in range(1, 14):
    derive_from_dragonfly_template(
        wilson_animation_name=f"mime{i}",
        dragonfly_animation_name="idle",
        output_animation_name=f"mime{i}",
        animation_length_align=2,
        dragonfly_animation_range=[0, 1],
    )
