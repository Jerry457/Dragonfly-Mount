import re
from copy import deepcopy

import numpy as np
from utils import (
    abcd_to_transform,
    lerp_angle,
    relength_anim_frames,
    rotate_element,
    scaling_element,
    transform_element,
    transform_to_abcd,
)


def get_parent_transform(parent_element, params):
    if (
        params["inherit_scale"]
        and params["inherit_rotation"]
        and not params["average_rotation"]
    ):
        return [
            [parent_element["a"], parent_element["c"]],
            [parent_element["b"], parent_element["d"]],
        ]

    transform = abcd_to_transform(
        parent_element["a"],
        parent_element["b"],
        parent_element["c"],
        parent_element["d"],
    )

    scale_x = transform["scale_x"] if params["inherit_scale"] else 1
    scale_y = transform["scale_y"] if params["inherit_scale"] else 1
    shear_x = transform["shear_x"] if params["inherit_rotation"] else 0
    shear_y = transform["shear_y"] if params["inherit_rotation"] else 0

    if params["inherit_rotation"] and params["average_rotation"]:
        diff = (shear_x - shear_y) * (np.pi / 180)
        if np.cos(diff) < 0:
            shear_x -= 180
            scale_x = -scale_x
        average = lerp_angle(shear_x, shear_y, 0.5)
        shear_x = shear_y = average

    abcd = transform_to_abcd(
        {
            "scale_x": scale_x,
            "scale_y": scale_y,
            "angle": 0,
            "shear_x": shear_x,
            "shear_y": shear_y,
        }
    )

    return [[abcd["a"], abcd["c"]], [abcd["b"], abcd["d"]]]


def follow_single_frame(
    idx,
    child_frame,
    parent_frame,
    local_x,
    local_y,
    local_scale_x,
    local_scale_y,
    local_rotate,
    z_index_offset,
    params,
):
    if callable(z_index_offset):
        z_index_offset = z_index_offset(idx)

    lower_follow_symbol = params["follow_symbol"].lower()
    follow_elements = {}

    for i, element in enumerate(parent_frame["elements"]):
        if element["symbol"].lower() == lower_follow_symbol and (
            not params["follow_num"].strip()
            or re.compile(params["follow_num"], re.IGNORECASE).match(
                str(element["frameNum"])
            )
        ):
            follow_elements[i + 1] = element
            if not params["follow_all_match"]:
                break

    if not follow_elements:
        return False

    for element in child_frame["elements"]:
        scaling_element(element, local_scale_x, local_scale_y)
        rotate_element(element, local_rotate)
        element["tx"] += local_x
        element["ty"] += local_y

    insert_indices = sorted(follow_elements.keys(), reverse=True)

    for index in insert_indices:
        parent_element = follow_elements[index]
        insert_index = max(
            0, min(index + z_index_offset, len(parent_frame["elements"]))
        )

        parent_transform = get_parent_transform(parent_element, params)
        parent_tx = parent_element["tx"] if params["inherit_pos_x"] else 0
        parent_ty = parent_element["ty"] if params["inherit_pos_y"] else 0

        insert_elements = deepcopy(child_frame["elements"])
        for element in insert_elements:
            transform_element(element, parent_transform)
            element["tx"] += parent_tx
            element["ty"] += parent_ty

        parent_frame["elements"][insert_index:insert_index] = insert_elements

    for idx, element in enumerate(parent_frame["elements"]):
        element["zIndex"] = idx

    return True


def apply_follow_symbol(
    animation,
    child,
    params={
        "follow_symbol": "dragonfly_head",
        "follow_num": r"\d+",
        "follow_all_match": False,
        "local_x": 0,
        "local_y": 0,
        "local_scale_x": 1,
        "local_scale_y": 1,
        "local_rotate": 0,
        "z_index_offset": 0,
        "inherit_pos_x": True,
        "inherit_pos_y": True,
        "inherit_scale": True,
        "inherit_rotation": True,
        "average_rotation": True,
        "alignment": 1,
        "interpolate": True,
    },
):
    if not child or not animation:
        return

    child = deepcopy(child)
    parent = deepcopy(animation)

    local_x_val = params["local_x"]
    local_y_val = params["local_y"]
    local_scale_x_val = params["local_scale_x"]
    local_scale_y_val = params["local_scale_y"]
    local_rotate_val = params["local_rotate"]
    z_index_offset_val = params["z_index_offset"]

    if params["alignment"] == 1:
        child["frames"] = relength_anim_frames(
            child["frames"], len(parent["frames"]), params["interpolate"]
        )
    elif params["alignment"] == 2:
        parent["frames"] = relength_anim_frames(
            parent["frames"], len(child["frames"]), params["interpolate"]
        )

    max_frame_idx = min(len(child["frames"]) - 1, len(parent["frames"]) - 1)

    dirty = False
    for i in range(max_frame_idx + 1):
        child_frame = child["frames"][i]
        parent_frame = parent["frames"][i]

        if follow_single_frame(
            i,
            child_frame,
            parent_frame,
            local_x_val,
            local_y_val,
            local_scale_x_val,
            local_scale_y_val,
            local_rotate_val,
            z_index_offset_val,
            params,
        ):
            dirty = True

    if not dirty:
        print("No Corresponding Symbol Found")
        return

    return parent
