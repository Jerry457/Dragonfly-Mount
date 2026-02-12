import os

os.chdir(os.path.dirname(os.path.abspath(__file__)))

from constant import *
from utils import *

SEP_FRAME = 25

baby_anim = load_anim("assets/dragonfly_mount_baby.json")
teen_anim = load_anim("assets/dragonfly_mount_teen.json")
adult_anim = load_anim("assets/dragonfly_mount.json")


def grow_pre_fn(
    anim,
    start_scale: float,
    end_scale: float,
):
    fire_on = get_animation(anim, "fire_on")
    fire_on["frames"] = fire_on["frames"][:SEP_FRAME]
    scale_grow = end_scale / start_scale
    scales = np.linspace(1.0, scale_grow, SEP_FRAME)
    for i in range(SEP_FRAME):
        scaling_anim_frame(fire_on["frames"][i], scales[i], scales[i])
        for element in fire_on["frames"][i]["elements"]:
            if str.lower(element["symbol"]) == "dragonfly_head":
                element["frameNum"] = 0
    fire_on["name"] = "grow_pre"
    return fire_on


def grow_pst_fn(
    anim,
):
    fire_on = get_animation(anim, "fire_on")
    fire_on["frames"] = fire_on["frames"][SEP_FRAME:]
    fire_on["name"] = "grow_pst"
    for frame in fire_on["frames"]:
        for element in frame["elements"]:
            if str.lower(element["symbol"]) == "dragonfly_head":
                element["frameNum"] = 0
    return fire_on


# baby
baby_grow_pre = grow_pre_fn(baby_anim, 0.35, 0.65)
baby_grow_pst = grow_pst_fn(baby_anim)

save_animations(
    [baby_grow_pre, baby_grow_pst],
    "dragonfly_mount_baby",
    "dragonfly_mount_baby_grow.json",
)

# teen
teen_grow_pre = grow_pre_fn(teen_anim, 0.65, 1)
teen_grow_pst = grow_pst_fn(teen_anim)

save_animations(
    [teen_grow_pre, teen_grow_pst],
    "dragonfly_mount_teen",
    "dragonfly_mount_teen_grow.json",
)

# adult
adult_grow_pre = grow_pre_fn(adult_anim, 1.0, 1.0)
adult_grow_pst = grow_pst_fn(adult_anim)

save_animations(
    [adult_grow_pre, adult_grow_pst],
    "dragonfly_mount",
    "dragonfly_mount_grow.json",
)
