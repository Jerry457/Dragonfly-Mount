# import os
# import sys

# sys.path.append(
#     os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# )
# from anti_follow_symbol import apply_anti_follow_symbol
# from constant import *
# from follow_symbol import apply_follow_symbol
# from utils import *

# wilsonbeefalo_anim = load_anim("assets/wilsonbeefalo.json")
# dragonfly_anim = load_anim("assets/dragonfly_emotes.json")

# wilson_idle = get_animation(wilsonbeefalo_anim, "idle_loop")
# wilson_idle = apply_anti_follow_symbol(
#     wilson_idle,
#     {
#         "anti_symbol": "beefalo_headbase",
#         "follow_num": "",
#         "maintain_scale": True,
#     },
# )

# # ===============================================================

# wilson_animation = get_animation(wilsonbeefalo_anim, "emoteXL_waving4")

# wilson_animation = apply_anti_follow_symbol(
#     wilson_animation,
#     {
#         "anti_symbol": "beefalo_headbase",
#         "follow_num": "",
#         "maintain_scale": True,
#     },
# )

# wilson_animation = remove_beefalo_elements(wilson_animation)

# fix_swap_saddle(wilson_animation, True, True, wilson_idle)

# dragonfly_idle = get_animation(dragonfly_anim, "warm_up")

# front, back = split_wilson_down_animation(wilson_animation)

# dragonfly_idle = apply_follow_symbol(
#     dragonfly_idle,
#     front,
#     params={
#         "follow_symbol": "dragonfly_head",
#         "follow_num": r"\d+",
#         "follow_all_match": False,
#         "local_x": -DOWN_DIR_X_OFFSET,
#         "local_y": DOWN_DIR_Y_OFFSET,
#         "local_scale_x": -LOCAL_SCALE_X,
#         "local_scale_y": LOCAL_SCALE_Y,
#         "local_rotate": 0,
#         "z_index_offset": -1,
#         "inherit_pos_x": True,
#         "inherit_pos_y": True,
#         "inherit_scale": True,
#         "inherit_rotation": False,
#         "average_rotation": True,
#         "alignment": 1,
#         "interpolate": True,
#     },
# )


# def local_x(element):
#     if str.lower(element["symbol"]) == "swap_saddle":
#         return DOWN_DIR_X_OFFSET
#     return -DOWN_DIR_X_OFFSET


# def local_scale_x(element):
#     if str.lower(element["symbol"]) == "swap_saddle":
#         return LOCAL_SCALE_X
#     return -LOCAL_SCALE_X


# def inherit_rotation(element):
#     if str.lower(element["symbol"]) == "swap_saddle":
#         return True
#     return False


# dragonfly_idle = apply_follow_symbol(
#     dragonfly_idle,
#     back,
#     params={
#         "follow_symbol": "dragonfly_head",
#         "follow_num": r"\d+",
#         "follow_all_match": False,
#         "local_x": local_x,
#         "local_y": DOWN_DIR_Y_OFFSET,
#         "local_scale_x": local_scale_x,
#         "local_scale_y": LOCAL_SCALE_Y,
#         "local_rotate": 0,
#         "z_index_offset": 0,
#         "inherit_pos_x": True,
#         "inherit_pos_y": True,
#         "inherit_scale": True,
#         "inherit_rotation": inherit_rotation,
#         "average_rotation": True,
#         "alignment": 1,
#         "interpolate": True,
#     },
# )

# dragonfly_idle["name"] = "emoteXL_waving4"  # type: ignore
# save_animation(dragonfly_idle, f"target/emoteXL_waving4.json")
