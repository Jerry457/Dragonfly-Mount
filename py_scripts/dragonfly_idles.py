import os

os.chdir(os.path.dirname(os.path.abspath(__file__)))

from constant import *
from utils import *

dragonfly_anim = load_anim("assets/dragonfly.json")

TY_MOVE_MULT = 0.5

idles = ["idle", "idle_side", "idle_upside"]

new_animations = []
for idle in idles:
    idle_animation = get_animation(dragonfly_anim, idle)

    ref_ty = None
    for frame in idle_animation["frames"]:  # type: ignore
        now_ty = None
        for element in frame["elements"]:
            if str.lower(element["symbol"]) == "dragonfly_head":
                now_ty = element["ty"]
                if ref_ty is None:
                    ref_ty = now_ty

        if ref_ty and now_ty:
            diff = (now_ty - ref_ty) * TY_MOVE_MULT
            for element in frame["elements"]:
                element["ty"] = element["ty"] - diff

    new_animations.append(idle_animation)

save_animations(new_animations, "dragonfly_idles", "dragonfly_idles.json")
