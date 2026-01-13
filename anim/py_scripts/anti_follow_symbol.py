import re
from copy import deepcopy

import numpy as np

from utils import (
    abcd_to_transform,
    transform_element,
)

# ======================== Functions ========================


def anti_follow_single_frame(frame, params):
    """
    Perform the anti-follow operation on a single frame.
    :param frame: The animation frame to process.
    :return: True if the operation was applied, False otherwise.
    """
    lower_anti_symbol = params["anti_symbol"].lower()
    follow_num = params["follow_num"]
    maintain_scale = params["maintain_scale"]

    follow_num_regex = None
    if follow_num.strip():
        try:
            follow_num_regex = re.compile(follow_num, re.IGNORECASE)
        except re.error:
            follow_num_regex = None

    parent_element = None

    for element in frame["elements"]:
        if element["symbol"].lower() == lower_anti_symbol and (
            not follow_num.strip()
            or follow_num_regex is None
            or follow_num_regex.match(str(element["frameNum"]))
        ):
            # Match the first corresponding element
            parent_element = element
            break

    if not parent_element:
        return False

    parent_m = [
        [parent_element["a"], parent_element["c"]],
        [parent_element["b"], parent_element["d"]],
    ]
    inv_parent_m = np.linalg.inv(parent_m)

    if maintain_scale:
        # Retain the scale of the corresponding symbol
        transform = abcd_to_transform(
            parent_element["a"],
            parent_element["b"],
            parent_element["c"],
            parent_element["d"],
        )
        scale_x = transform["scale_x"]
        scale_y = transform["scale_y"]
        scale_m = [[scale_x, 0], [0, scale_y]]
        inv_parent_m = np.dot(scale_m, inv_parent_m)

    parent_tx = parent_element["tx"]
    parent_ty = parent_element["ty"]

    for element in frame["elements"]:
        element["tx"] -= parent_tx
        element["ty"] -= parent_ty
        transform_element(element, inv_parent_m)

    return True


def apply_anti_follow_symbol(
    animation,
    params={
        "anti_symbol": "swap_object",
        "follow_num": "",
        "maintain_scale": False,
    },
):
    """
    Apply the anti-follow operation to the entire animation.
    :param animation: The animation to process.
    :return: The updated animation if changes were made, None otherwise.
    """
    if not animation:
        return

    new_animation = deepcopy(animation)
    dirty = False

    for frame in new_animation["frames"]:
        if anti_follow_single_frame(frame, params):
            dirty = True

    if not dirty:
        print("No Corresponding Symbol Found")
        return None

    return new_animation
