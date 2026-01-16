import os

from utils import *

os.chdir(os.path.dirname(os.path.abspath(__file__)))


wilsonbeefalo_anim = load_anim("assets/wilsonbeefalo.json")

wilsonbeefalo_animations = list_animations(wilsonbeefalo_anim)

wilsondragonfly_anim = load_anim("wilsondragonfly.json")

wilsondragonfly_animations = list_animations(wilsondragonfly_anim)

# 输出所有在wilsonbeefalo_animations里面有存在，但是wilsondragonfly_animations里面不存在的动画

missing_animations = set(wilsonbeefalo_animations) - set(wilsondragonfly_animations)
print(missing_animations)
