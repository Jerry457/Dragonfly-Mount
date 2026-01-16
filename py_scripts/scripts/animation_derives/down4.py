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
    post_init_wilson_animation=None,
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

    if post_init_wilson_animation:
        post_init_wilson_animation(wilson_animation)

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


# ================= upgrade_pre

derive_from_dragonfly_template(
    wilson_animation_name="upgrade_pre",
    dragonfly_animation_name="idle",
    output_animation_name="upgrade_pre",
    dragonfly_animation_range=[0, 6],
)

derive_from_dragonfly_template(
    wilson_animation_name="upgrade_lag",
    dragonfly_animation_name="idle",
    output_animation_name="upgrade_lag",
    dragonfly_animation_range=[6, 8],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="upgrade",
    dragonfly_animation_name="idle",
    output_animation_name="upgrade",
    dragonfly_animation_range=[8, None],
    dragonfly_animation_repeat=2,
)

# ================= walk_graze2

derive_from_dragonfly_template(
    wilson_animation_name="walk_graze2_pre",
    dragonfly_animation_name="walk_pre_downside",
    output_animation_name="walk_graze2_pre",
)

derive_from_dragonfly_template(
    wilson_animation_name="walk_graze2_loop",
    dragonfly_animation_name="walk_downside",
    output_animation_name="walk_graze2_loop",
)

derive_from_dragonfly_template(
    wilson_animation_name="walk_graze2_pst",
    dragonfly_animation_name="walk_pst_downside",
    output_animation_name="walk_graze2_pst",
)

# ================= wanda_old

derive_from_dragonfly_template(
    wilson_animation_name="wanda_old",
    dragonfly_animation_name="idle",
    output_animation_name="wanda_old",
    split_front_back=False,
)

derive_from_dragonfly_template(
    wilson_animation_name="wanda_young",
    dragonfly_animation_name="idle",
    output_animation_name="wanda_young",
    split_front_back=False,
)

# ================= webber_spider_whistle

derive_from_dragonfly_template(
    wilson_animation_name="webber_spider_whistle",
    dragonfly_animation_name="idle",
    output_animation_name="webber_spider_whistle",
)

# ================= wendy_channel

derive_from_dragonfly_template(
    wilson_animation_name="wendy_channel",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_channel",
    split_front_back=False,
)

derive_from_dragonfly_template(
    wilson_animation_name="wendy_channel_pst",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_channel_pst",
    dragonfly_animation_repeat=2,
    split_front_back=False,
)

# ================= wendy_commune

derive_from_dragonfly_template(
    wilson_animation_name="wendy_commune_pre",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_commune_pre",
    dragonfly_animation_range=[0, 7],
)

derive_from_dragonfly_template(
    wilson_animation_name="wendy_commune_lag",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_commune_lag",
    dragonfly_animation_range=[7, 9],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="wendy_commune_pst",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_commune_pst",
    dragonfly_animation_range=[9, None],
    dragonfly_animation_repeat=2,
    split_front_back=False,
)


# ================= wendy_elixir

derive_from_dragonfly_template(
    wilson_animation_name="wendy_elixir_pre",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_elixir_pre",
    dragonfly_animation_range=[0, 12],
)

derive_from_dragonfly_template(
    wilson_animation_name="wendy_elixir_lag",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_elixir_lag",
    dragonfly_animation_range=[12, 14],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="wendy_elixir",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_elixir",
    dragonfly_animation_range=[14, None],
    split_front_back=False,
)


# ================= wendy_recall

derive_from_dragonfly_template(
    wilson_animation_name="wendy_recall",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_recall",
    dragonfly_animation_range=[0, 18],
)

derive_from_dragonfly_template(
    wilson_animation_name="wendy_recall_lag",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_recall_lag",
    dragonfly_animation_range=[18, 20],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="wendy_recall_pst",
    dragonfly_animation_name="idle",
    output_animation_name="wendy_recall_pst",
    dragonfly_animation_range=[20, None],
)

# ================= whistle

derive_from_dragonfly_template(
    wilson_animation_name="whistle",
    dragonfly_animation_name="idle",
    output_animation_name="whistle",
    dragonfly_animation_repeat=2,
)

# ================= wormwood_cast_spawn

derive_from_dragonfly_template(
    wilson_animation_name="wormwood_cast_spawn_pre",
    dragonfly_animation_name="idle",
    output_animation_name="wormwood_cast_spawn_pre",
    dragonfly_animation_range=[0, 4],
)

derive_from_dragonfly_template(
    wilson_animation_name="wormwood_cast_spawn_lag",
    dragonfly_animation_name="idle",
    output_animation_name="wormwood_cast_spawn_lag",
    dragonfly_animation_range=[4, 6],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="wormwood_cast_spawn",
    dragonfly_animation_name="idle",
    output_animation_name="wormwood_cast_spawn",
    dragonfly_animation_range=[6, None],
)

# ================= yawn

derive_from_dragonfly_template(
    wilson_animation_name="yawn",
    dragonfly_animation_name="idle",
    output_animation_name="yawn",
)
