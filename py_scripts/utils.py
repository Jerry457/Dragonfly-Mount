import json
import re
from copy import deepcopy

import numpy as np


def load_anim(path):
    anim = json.load(open(path))
    return anim


def list_animations(anim):
    animations = []
    for bank in anim["banks"]:
        for animation in bank["animations"]:
            animations.append(animation["name"])
            print(animation["name"])
    return animations


def get_animation(anim, animation_name):
    for bank in anim["banks"]:
        for animation in bank["animations"]:
            if animation_name == animation["name"]:
                return deepcopy(animation)


def save_animation(animation, path):
    anim = {
        "version": 4,
        "type": "Anim",
        "banks": [
            {
                "name": animation["name"],
                "animations": [animation],
            }
        ],
    }
    json.dump(anim, open(path, "w"), indent=None)


def save_animations(animations, name, path):
    anim = {
        "version": 4,
        "type": "Anim",
        "banks": [
            {
                "name": name,
                "animations": animations,
            }
        ],
    }
    json.dump(anim, open(path, "w"), indent=None)


def lerp(start, end, t):
    return start + (end - start) * t


def reduce_angle(angle):
    while angle < -180.0:
        angle += 360.0
    while angle >= 180.0:
        angle -= 360.0
    return angle


def get_rotation_dir(angle1, angle2):
    if np.sin((angle1 - angle2) / 180 * np.pi) > 0:
        return 1
    else:
        return -1


def lerp_angle(angle1, angle2, t):
    diff = reduce_angle(angle2 - angle1)
    return reduce_angle(angle1 + diff * t)


def transform_anim_frame(frame, mat):
    for element in frame["elements"]:
        transform_element(element, mat)


def transform_element(element, mat):
    txty = np.array([element["tx"], element["ty"]])
    abcd = np.array([[element["a"], element["c"]], [element["b"], element["d"]]])

    new_txty = np.dot(mat, txty)
    new_abcd = np.dot(mat, abcd)

    element["tx"], element["ty"] = new_txty
    element["a"], element["c"] = new_abcd[0]
    element["b"], element["d"] = new_abcd[1]


def rotate_anim_frame(frame, angle):
    for element in frame["elements"]:
        rotate_element(element, angle)


def rotate_element(element, angle):
    theta = np.radians(angle)
    cos, sin = np.cos(theta), np.sin(theta)
    rot_m = np.array([[cos, -sin], [sin, cos]])

    transform_element(element, rot_m)


def scaling_anim_frame(frame, sx, sy):
    for element in frame["elements"]:
        scaling_element(element, sx, sy)


def scaling_element(element, sx, sy):
    scale_m = np.array([[sx, 0], [0, sy]])
    transform_element(element, scale_m)


def abcd_to_transform(a, b, c, d):
    scale_x = np.sqrt(a**2 + b**2)
    scale_y = np.sqrt(c**2 + d**2)

    if scale_x == 0 or scale_y == 0:
        return {
            "scale_x": scale_x,
            "scale_y": scale_y,
            "angle": 0,
            "shear_x": 0,
            "shear_y": 0,
        }

    kx = np.degrees(np.arctan2(-b, a))
    ky = np.degrees(np.arctan2(c, d))

    return {
        "scale_x": scale_x,
        "scale_y": scale_y,
        "angle": 0.0,
        "shear_x": kx,
        "shear_y": ky,
    }


def transform_to_abcd(transform):
    scale_x, scale_y = transform["scale_x"], transform["scale_y"]
    shear_x, shear_y = (
        transform["shear_x"] + transform["angle"],
        transform["shear_y"] + transform["angle"],
    )

    rx, ry = np.radians(shear_x), np.radians(shear_y)

    a = scale_x * np.cos(rx)
    b = -scale_x * np.sin(rx)
    c = scale_y * np.sin(ry)
    d = scale_y * np.cos(ry)

    return {"a": a, "b": b, "c": c, "d": d}


def relength_anim_frames(old_frames, new_length, interpolate=False):
    old_length = len(old_frames)
    if old_length == 0 or new_length == 0:
        return []

    if new_length == old_length:
        return deepcopy(old_frames)

    if new_length == 1:
        return [deepcopy(old_frames[0])]

    new_frames = []
    ratio = (old_length - 1) / (new_length - 1)

    for i in range(new_length):
        t = i * ratio
        index = round(t)
        if not interpolate or abs(t - index) < 0.05:
            new_frames.append(deepcopy(old_frames[index]))
        else:
            index = int(t)
            t = t - index
            new_frame = interpolate_frame(old_frames[index], old_frames[index + 1], t)
            new_frames.append(new_frame)

    for idx, frame in enumerate(new_frames):
        frame["idx"] = idx

    return new_frames


def can_frame_interpolate(frame1, frame2):
    if len(frame1["elements"]) != len(frame2["elements"]):
        return False

    for elem1, elem2 in zip(frame1["elements"], frame2["elements"]):
        if (
            elem1["symbol"].lower() != elem2["symbol"].lower()
            or elem1["frameNum"] != elem2["frameNum"]
            or elem1["layerName"] != elem2["layerName"]
        ):
            return False

    return True


def interpolate_frame(frame1, frame2, t):
    if not can_frame_interpolate(frame1, frame2):
        return deepcopy(frame1 if t < 0.5 else frame2)

    new_frame = deepcopy(frame1)
    for i, (elem1, elem2) in enumerate(zip(frame1["elements"], frame2["elements"])):
        transform1 = abcd_to_transform(elem1["a"], elem1["b"], elem1["c"], elem1["d"])
        transform2 = abcd_to_transform(elem2["a"], elem2["b"], elem2["c"], elem2["d"])

        # 前后帧shear轴的顺逆时针关系不同，不进行插值
        old_shear_dir = get_rotation_dir(transform1["shear_x"], transform1["shear_y"])
        new_shear_dir = get_rotation_dir(transform2["shear_x"], transform2["shear_y"])
        if old_shear_dir * new_shear_dir < 0:
            continue

        scale_x = lerp(transform1["scale_x"], transform2["scale_x"], t)
        scale_y = lerp(transform1["scale_y"], transform2["scale_y"], t)
        shear_x = lerp_angle(transform1["shear_x"], transform2["shear_x"], t)
        shear_y = lerp_angle(transform1["shear_y"], transform2["shear_y"], t)

        abcd = transform_to_abcd(
            {
                "scale_x": scale_x,
                "scale_y": scale_y,
                "shear_x": shear_x,
                "shear_y": shear_y,
                "angle": 0,
            }
        )
        tx = lerp(elem1["tx"], elem2["tx"], t)
        ty = lerp(elem1["ty"], elem2["ty"], t)

        new_frame["elements"][i].update(
            {
                "a": abcd["a"],
                "b": abcd["b"],
                "c": abcd["c"],
                "d": abcd["d"],
                "tx": tx,
                "ty": ty,
            }
        )

    return new_frame


# ============================================================


def remove_beefalo_elements(animation):
    new = deepcopy(animation)

    for frame in new["frames"]:
        frame["elements"] = [
            element
            for element in frame["elements"]
            if (
                element["symbol"] != "swap_fire"
                and not re.match("beefalo", element["symbol"], re.IGNORECASE)
            )
        ]

        frame["elements"].sort(key=lambda x: x["zIndex"])
        for i in range(len(frame["elements"])):
            frame["elements"][i]["zIndex"] = i

    return new


def split_wilson_down_animation(animation):
    front = deepcopy(animation)

    re_str = r"^(headbase|SWAP_FACE|headbase_hat|face|hairfront|HAIR_HAT|hair|BEARD|swap_hat|hand)$"

    for frame in front["frames"]:
        frame["elements"] = [
            element
            for element in frame["elements"]
            if (
                re.match(
                    re_str,
                    element["symbol"],
                    re.IGNORECASE,
                )
                and (
                    str.lower(element["symbol"]) != "hand"
                    or (element["frameNum"] == 18 or element["frameNum"] == 19)
                )
            )
        ]

        frame["elements"].sort(key=lambda x: x["zIndex"])
        for i in range(len(frame["elements"])):
            frame["elements"][i]["zIndex"] = i

    back = deepcopy(animation)

    for frame in back["frames"]:
        frame["elements"] = [
            element
            for element in frame["elements"]
            if not (
                re.match(
                    re_str,
                    element["symbol"],
                    re.IGNORECASE,
                )
                and (
                    str.lower(element["symbol"]) != "hand"
                    or (element["frameNum"] == 18 or element["frameNum"] == 19)
                )
            )
        ]

        frame["elements"].sort(key=lambda x: x["zIndex"])
        for i in range(len(frame["elements"])):
            frame["elements"][i]["zIndex"] = i

    return front, back


def split_wilson_side_animation(animation):
    front = deepcopy(animation)

    re_str = r"^(headbase|SWAP_FACE|headbase_hat|face|hairfront|HAIR_HAT|hair|BEARD|swap_hat)$"

    for frame in front["frames"]:
        frame["elements"] = [
            element
            for element in frame["elements"]
            if (
                re.match(
                    re_str,
                    element["symbol"],
                    re.IGNORECASE,
                )
            )
        ]

        frame["elements"].sort(key=lambda x: x["zIndex"])
        for i in range(len(frame["elements"])):
            frame["elements"][i]["zIndex"] = i

    back = deepcopy(animation)

    for frame in back["frames"]:
        frame["elements"] = [
            element
            for element in frame["elements"]
            if not (
                re.match(
                    re_str,
                    element["symbol"],
                    re.IGNORECASE,
                )
            )
        ]

        frame["elements"].sort(key=lambda x: x["zIndex"])
        for i in range(len(frame["elements"])):
            frame["elements"][i]["zIndex"] = i

    return front, back


def joint_animations(animations, name):
    new = deepcopy(animations[0])
    new["frames"] = []

    for i in range(len(animations)):
        for j in range(len(animations[i]["frames"])):
            new["frames"].append(animations[i]["frames"][j])

    for i in range(len(new["frames"])):
        frame = new["frames"][i]
        frame["idx"] = i

    new["name"] = name
    return new


def fix_swap_saddle(
    wilson_animation,
    fix_swap_saddle_scale=True,
    fix_swap_saddle_pos=True,
    custom_saddle_pos_animation=None,
):
    if fix_swap_saddle_scale or fix_swap_saddle_pos:
        swap_saddle_x = None
        swap_saddle_y = None

        if custom_saddle_pos_animation:
            frame = custom_saddle_pos_animation["frames"][0]
            for element in frame["elements"]:
                if str.lower(element["symbol"]) == "swap_saddle":
                    swap_saddle_x = element["tx"]
                    swap_saddle_y = element["ty"]
                    break

        for frame in wilson_animation["frames"]:  # type: ignore
            for element in frame["elements"]:
                if str.lower(element["symbol"]) == "swap_saddle":
                    if fix_swap_saddle_scale:
                        element["a"] = 0.705
                        element["b"] = 0.0
                        element["c"] = 0.0
                        element["d"] = 0.705
                    if fix_swap_saddle_pos:
                        element["tx"] = swap_saddle_x or element["tx"]
                        element["ty"] = swap_saddle_y or element["ty"]
                        if swap_saddle_x is None:
                            swap_saddle_x = element["tx"]
                        if swap_saddle_y is None:
                            swap_saddle_y = element["ty"]
                    break


def reorder_animation(animation):
    for i, frame in enumerate(animation["frames"]):
        frame["idx"] = i
