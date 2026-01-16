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
    wilson_animation_name="idle_loop_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="idle_loop_upside",
    animation_length_align=1,
    dragonfly_animation_range=[None, None],
    fix_swap_saddle_scale=True,
    fix_swap_saddle_pos=True,
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
        ]  # type: ignore
    elif anim_range[0] is not None:
        dragonfly_idle["frames"] = dragonfly_idle["frames"][anim_range[0] :]  # type: ignore
    elif anim_range[1] is not None:
        dragonfly_idle["frames"] = dragonfly_idle["frames"][: anim_range[1]]  # type: ignore

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


# ================= dart

derive_from_dragonfly_template(
    wilson_animation_name="dart_pre_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="dart_pre_upside",
    dragonfly_animation_range=[0, 17],
)

derive_from_dragonfly_template(
    wilson_animation_name="dart_lag_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="dart_lag_upside",
    dragonfly_animation_range=[17, 20],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="dart_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="dart_upside",
    dragonfly_animation_range=[20, None],
)

# ================= atk_recoil_upside

derive_from_dragonfly_template(
    wilson_animation_name="atk_recoil_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="atk_recoil_upside",
    dragonfly_animation_range=[None, None],
)

# ================= useitem

derive_from_dragonfly_template(
    wilson_animation_name="useitem_dir_pre_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="useitem_dir_pre_upside",
    dragonfly_animation_range=[0, 14],
)

derive_from_dragonfly_template(
    wilson_animation_name="useitem_dir_lag_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="useitem_dir_lag_upside",
    dragonfly_animation_range=[14, 15],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="useitem_dir_pst_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="useitem_dir_pst_upside",
    dragonfly_animation_range=[15, None],
)

# ================= deploytoss_upside

derive_from_dragonfly_template(
    wilson_animation_name="deploytoss_pre_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="deploytoss_pre_upside",
    dragonfly_animation_range=[0, 12],
)

derive_from_dragonfly_template(
    wilson_animation_name="deploytoss_lag_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="deploytoss_lag_upside",
    dragonfly_animation_range=[12, 14],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="deploytoss_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="deploytoss_upside",
    dragonfly_animation_range=[14, None],
)

# ================= give_upside

derive_from_dragonfly_template(
    wilson_animation_name="give_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="give_upside",
    dragonfly_animation_range=[0, 18],
)

derive_from_dragonfly_template(
    wilson_animation_name="give_pst_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="give_pst_upside",
    dragonfly_animation_range=[18, None],
)

# ================= idle_walk_upside

derive_from_dragonfly_template(
    wilson_animation_name="idle_walk_pre_upside",
    dragonfly_animation_name="walk_upside",
    output_animation_name="idle_walk_pre_upside",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="idle_walk_upside",
    dragonfly_animation_name="walk_upside",
    output_animation_name="idle_walk_upside",
    dragonfly_animation_repeat=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="idle_walk_pst_upside",
    dragonfly_animation_name="walk_upside",
    output_animation_name="idle_walk_pst_upside",
    dragonfly_animation_range=[-2, None],
    animation_length_align=2,
)

# ================= pickup

derive_from_dragonfly_template(
    wilson_animation_name="pickup_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="pickup_upside",
    dragonfly_animation_range=[0, 10],
)

derive_from_dragonfly_template(
    wilson_animation_name="pickup_lag_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="pickup_lag_upside",
    dragonfly_animation_range=[10, 14],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="pickup_pst_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="pickup_pst_upside",
    dragonfly_animation_range=[14, None],
)

# ================= player_atk

derive_from_dragonfly_template(
    wilson_animation_name="player_atk_pre_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="player_atk_pre_upside",
    dragonfly_animation_range=[0, 10],
)

derive_from_dragonfly_template(
    wilson_animation_name="player_atk_lag_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="player_atk_lag_upside",
    dragonfly_animation_range=[10, 14],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="player_atk_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="player_atk_upside",
    dragonfly_animation_range=[14, None],
)

# ================= remotecast

derive_from_dragonfly_template(
    wilson_animation_name="remotecast_pre_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="remotecast_pre_upside",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="remotecast_loop_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="remotecast_loop_upside",
)

derive_from_dragonfly_template(
    wilson_animation_name="remotecast_pst_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="remotecast_pst_upside",
    dragonfly_animation_range=[-2, None],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="remotecast_trigger_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="remotecast_trigger_upside",
    dragonfly_animation_range=[0, 11],
)

# ================= sand_idle_loop

derive_from_dragonfly_template(
    wilson_animation_name="sand_idle_pre_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="sand_idle_pre_upside",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="sand_idle_loop_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="sand_idle_loop_upside",
    dragonfly_animation_repeat=2,
)

# ================= slingshot_alt_pre_upside

derive_from_dragonfly_template(
    wilson_animation_name="slingshot_alt_pre_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="slingshot_alt_pre_upside",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

# ================= slingshot_pre_upside

derive_from_dragonfly_template(
    wilson_animation_name="slingshot_pre_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="slingshot_pre_upside",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)


# ================= slingshot_downside

derive_from_dragonfly_template(
    wilson_animation_name="slingshot_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="slingshot_upside",
    animation_length_align=2,
)

# ================= slingshot_downside

derive_from_dragonfly_template(
    wilson_animation_name="slingshot_lag_upside",
    dragonfly_animation_name="idle_upside",
    output_animation_name="slingshot_lag_upside",
    dragonfly_animation_repeat=2,
)
