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

# ================= action_uniqueitem

derive_from_dragonfly_template(
    wilson_animation_name="action_uniqueitem_lag",
    dragonfly_animation_name="idle",
    output_animation_name="action_uniqueitem_lag",
    dragonfly_animation_range=[0, 15],
)

derive_from_dragonfly_template(
    wilson_animation_name="action_uniqueitem_pre",
    dragonfly_animation_name="idle",
    output_animation_name="action_uniqueitem_pre",
    dragonfly_animation_range=[0, 7],
    animation_length_align=2,
)

# ================= alert

derive_from_dragonfly_template(
    wilson_animation_name="alert_pre",
    dragonfly_animation_name="idle",
    output_animation_name="alert_pre",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="alert_idle",
    dragonfly_animation_name="idle",
    output_animation_name="alert_idle",
)

derive_from_dragonfly_template(
    wilson_animation_name="alert_pst",
    dragonfly_animation_name="idle",
    output_animation_name="alert_pst",
    dragonfly_animation_range=[-2, None],
    animation_length_align=2,
)


# ================= book

derive_from_dragonfly_template(
    wilson_animation_name="book",
    dragonfly_animation_name="idle",
    output_animation_name="book",
)

# ================= atk_recoil_downside

derive_from_dragonfly_template(
    wilson_animation_name="atk_recoil_downside",
    dragonfly_animation_name="idle",
    output_animation_name="atk_recoil_downside",
)

# ================= bell

derive_from_dragonfly_template(
    wilson_animation_name="bell",
    dragonfly_animation_name="idle",
    output_animation_name="bell",
)

# ================= eat

derive_from_dragonfly_template(
    wilson_animation_name="bell",
    dragonfly_animation_name="idle",
    output_animation_name="bell",
)

# ================= quick_drink

derive_from_dragonfly_template(
    wilson_animation_name="quick_drink_pre",
    dragonfly_animation_name="idle",
    output_animation_name="quick_drink_pre",
    dragonfly_animation_range=[0, 18],
)

derive_from_dragonfly_template(
    wilson_animation_name="quick_drink",
    dragonfly_animation_name="idle",
    output_animation_name="quick_drink",
    dragonfly_animation_range=[19, None],
)

derive_from_dragonfly_template(
    wilson_animation_name="quick_drink_lag",
    dragonfly_animation_name="idle",
    output_animation_name="quick_drink_lag",
    dragonfly_animation_range=[18, 19],
    animation_length_align=2,
)

# ================= quick_eat

derive_from_dragonfly_template(
    wilson_animation_name="quick_eat_pre",
    dragonfly_animation_name="idle",
    output_animation_name="quick_eat_pre",
    dragonfly_animation_range=[0, 18],
)

derive_from_dragonfly_template(
    wilson_animation_name="quick_eat",
    dragonfly_animation_name="idle",
    output_animation_name="quick_eat",
    dragonfly_animation_range=[19, None],
)

derive_from_dragonfly_template(
    wilson_animation_name="quick_eat_lag",
    dragonfly_animation_name="idle",
    output_animation_name="quick_eat_lag",
    dragonfly_animation_range=[18, 19],
    animation_length_align=2,
)

# ================= useitem

derive_from_dragonfly_template(
    wilson_animation_name="useitem_pre",
    dragonfly_animation_name="idle",
    output_animation_name="useitem_pre",
    dragonfly_animation_range=[0, 14],
)

derive_from_dragonfly_template(
    wilson_animation_name="useitem_lag",
    dragonfly_animation_name="idle",
    output_animation_name="useitem_lag",
    dragonfly_animation_range=[14, 15],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="useitem_pst",
    dragonfly_animation_name="idle",
    output_animation_name="useitem_pst",
    dragonfly_animation_range=[15, None],
)

# ================= useitem

derive_from_dragonfly_template(
    wilson_animation_name="useitem_dir_pre",
    dragonfly_animation_name="idle",
    output_animation_name="useitem_dir_pre",
    dragonfly_animation_range=[0, 14],
)

derive_from_dragonfly_template(
    wilson_animation_name="useitem_dir_lag",
    dragonfly_animation_name="idle",
    output_animation_name="useitem_dir_lag",
    dragonfly_animation_range=[14, 15],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="useitem_dir_pst",
    dragonfly_animation_name="idle",
    output_animation_name="useitem_dir_pst",
    dragonfly_animation_range=[15, None],
)


# ================= deploytoss_downside

derive_from_dragonfly_template(
    wilson_animation_name="deploytoss_pre_downside",
    dragonfly_animation_name="idle",
    output_animation_name="deploytoss_pre_downside",
    dragonfly_animation_range=[0, 12],
)

derive_from_dragonfly_template(
    wilson_animation_name="deploytoss_lag_downside",
    dragonfly_animation_name="idle",
    output_animation_name="deploytoss_lag_downside",
    dragonfly_animation_range=[12, 14],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="deploytoss_downside",
    dragonfly_animation_name="idle",
    output_animation_name="deploytoss_downside",
    dragonfly_animation_range=[14, None],
)

# ================= dialog_loop

derive_from_dragonfly_template(
    wilson_animation_name="dialog_loop",
    dragonfly_animation_name="idle",
    output_animation_name="dialog_loop",
    dragonfly_animation_range=[None, None],
)

# ================= dial_loop

derive_from_dragonfly_template(
    wilson_animation_name="dial_loop",
    dragonfly_animation_name="idle",
    output_animation_name="dial_loop",
    dragonfly_animation_range=[None, None],
)

# ================= downgrade

derive_from_dragonfly_template(
    wilson_animation_name="downgrade",
    dragonfly_animation_name="idle",
    output_animation_name="downgrade",
    dragonfly_animation_range=[None, None],
)

# ================= drink

derive_from_dragonfly_template(
    wilson_animation_name="drink_pre",
    dragonfly_animation_name="idle",
    output_animation_name="drink_pre",
    dragonfly_animation_range=[0, 8],
)

derive_from_dragonfly_template(
    wilson_animation_name="drink_lag",
    dragonfly_animation_name="idle",
    output_animation_name="drink_lag",
    dragonfly_animation_range=[8, 9],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="drink",
    dragonfly_animation_name="idle",
    output_animation_name="drink",
    dragonfly_animation_range=[9, None],
)

# ================= fan

derive_from_dragonfly_template(
    wilson_animation_name="fan",
    dragonfly_animation_name="idle",
    output_animation_name="fan",
    dragonfly_animation_repeat=3,
)


# ================= fertilize

derive_from_dragonfly_template(
    wilson_animation_name="fertilize_pre",
    dragonfly_animation_name="idle",
    output_animation_name="fertilize_pre",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="fertilize_lag",
    dragonfly_animation_name="idle",
    output_animation_name="fertilize_lag",
    dragonfly_animation_range=[2, 4],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="fertilize",
    dragonfly_animation_name="idle",
    output_animation_name="fertilize",
    split_front_back=False,
    dragonfly_animation_range=[4, None],
    dragonfly_animation_repeat=2,
)

# ================= flute

derive_from_dragonfly_template(
    wilson_animation_name="flute",
    dragonfly_animation_name="idle",
    output_animation_name="flute",
    dragonfly_animation_range=[None, None],
    dragonfly_animation_repeat=3,
)

# ================= form_log

derive_from_dragonfly_template(
    wilson_animation_name="form_log_pre",
    dragonfly_animation_name="idle",
    output_animation_name="form_log_pre",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="form_log_lag",
    dragonfly_animation_name="idle",
    output_animation_name="form_log_lag",
    dragonfly_animation_range=[2, 4],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="form_log",
    dragonfly_animation_name="idle",
    output_animation_name="form_log",
    dragonfly_animation_range=[4, None],
    dragonfly_animation_repeat=2,
)

# ================= frozen

derive_from_dragonfly_template(
    wilson_animation_name="frozen",
    dragonfly_animation_name="frozen",
    output_animation_name="frozen",
    dragonfly_animation_range=[None, None],
)

derive_from_dragonfly_template(
    wilson_animation_name="frozen_loop_pst",
    dragonfly_animation_name="frozen_loop_pst",
    output_animation_name="frozen_loop_pst",
    dragonfly_animation_range=[None, None],
)

# ================= give

derive_from_dragonfly_template(
    wilson_animation_name="give",
    dragonfly_animation_name="idle",
    output_animation_name="give",
    dragonfly_animation_range=[0, 18],
)

derive_from_dragonfly_template(
    wilson_animation_name="give_pst",
    dragonfly_animation_name="idle",
    output_animation_name="give_pst",
    dragonfly_animation_range=[18, None],
)

# ================= graze_loop

derive_from_dragonfly_template(
    wilson_animation_name="graze_loop",
    dragonfly_animation_name="idle",
    output_animation_name="graze_loop",
    dragonfly_animation_range=[None, None],
)


# ================= graze2

derive_from_dragonfly_template(
    wilson_animation_name="graze2_pre",
    dragonfly_animation_name="idle",
    output_animation_name="graze2_pre",
    dragonfly_animation_range=[0, 6],
)

derive_from_dragonfly_template(
    wilson_animation_name="graze2_loop",
    dragonfly_animation_name="idle",
    output_animation_name="graze2_loop",
    dragonfly_animation_range=[6, -6],
)

derive_from_dragonfly_template(
    wilson_animation_name="graze2_pst",
    dragonfly_animation_name="idle",
    output_animation_name="graze2_pst",
    dragonfly_animation_range=[-6, None],
)


# ================= heavy_mount

derive_from_dragonfly_template(
    wilson_animation_name="heavy_mount",
    dragonfly_animation_name="idle",
    output_animation_name="heavy_mount",
    split_front_back=False,
)

# ================= hit_darkness


def pre_init_hit_darkness(wilson_animation):
    for frame in wilson_animation["frames"]:
        if frame["idx"] >= 2 and frame["idx"] <= 16:
            for element in frame["elements"]:
                if str.lower(element["symbol"]) == "beefalo_headbase":
                    old_tx = element["tx"]
                    old_ty = element["ty"]
                    scaling_element(element, -1, 1)
                    element["tx"] = old_tx
                    element["ty"] = old_ty
                    break


derive_from_dragonfly_template(
    wilson_animation_name="hit_darkness",
    dragonfly_animation_name="idle",
    output_animation_name="hit_darkness",
    pre_init_wilson_animation=pre_init_hit_darkness,
)

# ================= horn

derive_from_dragonfly_template(
    wilson_animation_name="horn",
    dragonfly_animation_name="idle",
    output_animation_name="horn",
    dragonfly_animation_repeat=2,
)


# ================= hornblow

derive_from_dragonfly_template(
    wilson_animation_name="hornblow_pre",
    dragonfly_animation_name="idle",
    output_animation_name="hornblow_pre",
    dragonfly_animation_range=[0, 3],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="hornblow_lag",
    dragonfly_animation_name="idle",
    output_animation_name="hornblow_lag",
    dragonfly_animation_range=[3, 5],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="hornblow",
    dragonfly_animation_name="idle",
    output_animation_name="hornblow",
    dragonfly_animation_range=[5, None],
    dragonfly_animation_repeat=2,
)

# ================= idle_onemanband1

derive_from_dragonfly_template(
    wilson_animation_name="idle_onemanband1_pre",
    dragonfly_animation_name="idle",
    output_animation_name="idle_onemanband1_pre",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="idle_onemanband1_loop",
    dragonfly_animation_name="idle",
    output_animation_name="idle_onemanband1_loop",
)

derive_from_dragonfly_template(
    wilson_animation_name="idle_onemanband1_pst",
    dragonfly_animation_name="idle",
    output_animation_name="idle_onemanband1_pst",
    dragonfly_animation_range=[-2, None],
    animation_length_align=2,
)

# ================= idle_onemanband2

derive_from_dragonfly_template(
    wilson_animation_name="idle_onemanband2_pre",
    dragonfly_animation_name="idle",
    output_animation_name="idle_onemanband2_pre",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="idle_onemanband2_loop",
    dragonfly_animation_name="idle",
    output_animation_name="idle_onemanband2_loop",
)

derive_from_dragonfly_template(
    wilson_animation_name="idle_onemanband2_pst",
    dragonfly_animation_name="idle",
    output_animation_name="idle_onemanband2_pst",
    dragonfly_animation_range=[-2, None],
    animation_length_align=2,
)

# ================= idle_walk_downside

derive_from_dragonfly_template(
    wilson_animation_name="idle_walk_pre_downside",
    dragonfly_animation_name="walk_downside",
    output_animation_name="idle_walk_pre_downside",
    dragonfly_animation_range=[0, 2],
    animation_length_align=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="idle_walk_downside",
    dragonfly_animation_name="walk_downside",
    output_animation_name="idle_walk_downside",
    dragonfly_animation_repeat=2,
)

derive_from_dragonfly_template(
    wilson_animation_name="idle_walk_pst_downside",
    dragonfly_animation_name="walk_downside",
    output_animation_name="idle_walk_pst_downside",
    dragonfly_animation_range=[-2, None],
    animation_length_align=2,
)

# ================= item

derive_from_dragonfly_template(
    wilson_animation_name="item_hat",
    dragonfly_animation_name="idle",
    output_animation_name="item_hat",
)

derive_from_dragonfly_template(
    wilson_animation_name="item_in",
    dragonfly_animation_name="idle",
    output_animation_name="item_in",
)

derive_from_dragonfly_template(
    wilson_animation_name="item_out",
    dragonfly_animation_name="idle",
    output_animation_name="item_out",
)
