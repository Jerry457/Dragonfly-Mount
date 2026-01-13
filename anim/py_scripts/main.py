# python anim/py_scripts/main.py
import os
import subprocess
import threading
from time import time

from utils import *

os.chdir(os.path.dirname(os.path.abspath(__file__)))


start = time()


# 执行scripts文件夹下所有子文件夹中的python脚本
scripts_dir = "scripts"
threads = []


def run_scripts_in_folder(folder_path):
    for script in os.listdir(folder_path):
        if script.endswith(".py"):
            script_path = os.path.join(folder_path, script)
            subprocess.run(["python", script_path], check=True)
            print(f"Executed {script_path}")


for folder in os.listdir(scripts_dir):
    folder_path = os.path.join(scripts_dir, folder)
    if os.path.isdir(folder_path):
        thread = threading.Thread(target=run_scripts_in_folder, args=(folder_path,))
        threads.append(thread)
        thread.start()

# 等待所有线程完成
for thread in threads:
    thread.join()


# 合并target里面的所有anim
animations = []
print("Joint Animations")
for file in os.listdir("target"):
    if file.endswith(".json"):
        anim = load_anim(f"target/{file}")
        animation = anim["banks"][0]["animations"][0]
        animations.append(animation)

# 字符表排序动画
animations.sort(key=lambda x: x["name"])
save_animations(animations, "wilsondragonfly", "wilsondragonfly.json")

print(f"Time taken: {time() - start:.2f} seconds")
