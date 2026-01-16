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

    fix_swap_saddle(
        wilson_animation, fix_swap_saddle_scale, fix_swap_saddle_pos, wilson_idle
    )

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


emotes_pre = {
    "emote_pre_carol": 1,
    "emote_pre_toast": 1,
    "emoteXL_pre_dance0": 1,
    "emoteXL_pre_dance6": 1,
    "emoteXL_pre_dance7": 1,
    "emoteXL_pre_dance8": 1,
}

emotes = {
    "emote_angry": 2,
    "emote_annoyed_facepalm": 1,
    "emote_annoyed_palmdown": 1,
    "emote_feet": 1,
    "emote_flex": 2,
    "emote_hands": 2,
    "emote_happycheer": 2,
    "emote_hat": 1,
    "emote_hat_tip": 1,
    "emote_impatient": 2,
    "emote_jumpcheer": 1,
    "emote_laugh": 2,
    "emote_loop_carol": 2,
    "emote_loop_toast": 1,
    "emote_sad": 2,
    "emote_shrug": 1,
    "emote_sleepy": 2,
    "emote_slowclap": 2,
    "emote_strikepose": 2,
    "emote_swoon": 2,
    "emote_waving": 2,
    "emote_yawn": 2,
    "emoteXL_angry": 1,
    "emoteXL_annoyed": 2,
    "emoteXL_bonesaw": 2,
    "emoteXL_facepalm": 1,
    "emoteXL_kiss": 2,
    "emoteXL_loop_dance0": 1,
    "emoteXL_loop_dance6": 5,
    "emoteXL_loop_dance7": 3,
    "emoteXL_loop_dance8": 4,
    "emoteXL_sad": 2,
    "emoteXL_waving1": 1,
    "emoteXL_waving2": 1,
    "emoteXL_waving3": 1,
    "emoteXL_waving4": 1,
    "emoteXL_happycheer": 1,
    "emote_fistshake": 1,
}


emotes_pst = {
    "emote_pst_carol": 1,
    "emote_pst_toast": 1,
    "emoteXL_pst_dance0": 1,
    "emoteXL_pst_dance6": 1,
    "emoteXL_pst_dance8": 1,
}


for emote, repeat in emotes_pre.items():
    derive_from_dragonfly_template(
        wilson_animation_name=emote,
        dragonfly_animation_name="idle",
        output_animation_name=emote,
        dragonfly_animation_repeat=repeat,
        animation_length_align=2,
        dragonfly_animation_range=[0, 2],
    )

for emote, repeat in emotes.items():
    derive_from_dragonfly_template(
        wilson_animation_name=emote,
        dragonfly_animation_name="idle",
        output_animation_name=emote,
        dragonfly_animation_repeat=repeat,
    )

for emote, repeat in emotes_pst.items():
    derive_from_dragonfly_template(
        wilson_animation_name=emote,
        dragonfly_animation_name="idle",
        output_animation_name=emote,
        dragonfly_animation_repeat=repeat,
        animation_length_align=2,
        dragonfly_animation_range=[-2, None],
    )


# sit特殊处理
for i in range(4):
    derive_from_dragonfly_template(
        wilson_animation_name="emote_pre_sit1",
        dragonfly_animation_name="idle",
        output_animation_name=f"emote_pre_sit{i + 1}",
        dragonfly_animation_repeat=1,
        animation_length_align=2,
        dragonfly_animation_range=[0, 2],
    )

    derive_from_dragonfly_template(
        wilson_animation_name="emote_loop_sit1",
        dragonfly_animation_name="idle",
        output_animation_name=f"emote_loop_sit{i + 1}",
        dragonfly_animation_repeat=2,
    )

    derive_from_dragonfly_template(
        wilson_animation_name="emote_pst_sit1",
        dragonfly_animation_name="idle",
        output_animation_name=f"emote_pst_sit{i + 1}",
        dragonfly_animation_repeat=1,
        animation_length_align=2,
        dragonfly_animation_range=[-2, None],
    )
