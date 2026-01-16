# python anim/py_scripts/main.py
import hashlib
import json
import os
import subprocess
import threading
from time import time

from utils import *

os.chdir(os.path.dirname(os.path.abspath(__file__)))

start = time()

target_dir = "target"
os.makedirs(target_dir, exist_ok=True)

# 读取脚本上次执行时间
timestamps_file = os.path.join(target_dir, "script_timestamps.json")
if os.path.exists(timestamps_file):
    with open(timestamps_file, "r") as f:
        script_timestamps = json.load(f)
else:
    script_timestamps = {}


# 检查 target 目录中所有 JSON 文件的最后修改时间
def get_json_file_mod_times(directory):
    json_mod_times = {}
    for file in os.listdir(directory):
        if file.endswith(".json") and file != "script_timestamps.json":
            file_path = os.path.join(directory, file)
            json_mod_times[file] = os.path.getmtime(file_path)
    return json_mod_times


# 记录脚本执行前的 JSON 文件修改时间
pre_execution_json_mod_times = get_json_file_mod_times(target_dir)

# 执行scripts文件夹下所有子文件夹中的python脚本
scripts_dir = "scripts"
threads = []


def run_scripts_in_folder(folder_path):
    for script in os.listdir(folder_path):
        if script.endswith(".py"):
            script_path = os.path.join(folder_path, script)
            last_execution_time = script_timestamps.get(script_path, 0)
            script_mod_time = os.path.getmtime(script_path)

            if script_mod_time > last_execution_time:
                subprocess.run(["python", script_path], check=True)
                script_timestamps[script_path] = time()
                print(f"Executed {script_path}")
            else:
                print(f"Skipped {script_path} (no changes detected)")


for folder in os.listdir(scripts_dir):
    folder_path = os.path.join(scripts_dir, folder)
    if os.path.isdir(folder_path):
        thread = threading.Thread(target=run_scripts_in_folder, args=(folder_path,))
        threads.append(thread)
        thread.start()

# 等待所有线程完成
for thread in threads:
    thread.join()


# 保存脚本最后执行时间
with open(timestamps_file, "w") as f:
    json.dump(script_timestamps, f, indent=4)

# 记录脚本执行后的 JSON 文件修改时间
post_execution_json_mod_times = get_json_file_mod_times(target_dir)

# 筛选出更新或新生成的 JSON 文件
updated_or_new_json_files = [
    file
    for file, mod_time in post_execution_json_mod_times.items()
    if file not in pre_execution_json_mod_times
    or mod_time > pre_execution_json_mod_times[file]
]

# 合并更新或新生成的 JSON 文件
if updated_or_new_json_files:
    print("Merging updated or new JSON files into anim.json")
    animations = []
    for file in updated_or_new_json_files:
        anim = load_anim(os.path.join(target_dir, file))
        animation = anim["banks"][0]["animations"][0]
        animations.append(animation)

    # 字符表排序动画名称
    animations.sort(key=lambda x: x["name"])
    save_animations(animations, "wilsondragonfly", "update.json")
else:
    print("No updated or new JSON files found.")


# # 合并target里面的所有anim
# animations = []
# print("Joint Animations")
# for file in os.listdir(target_dir):
#     if file.endswith(".json") and file != "script_timestamps.json":
#         anim = load_anim(os.path.join(target_dir, file))
#         animation = anim["banks"][0]["animations"][0]
#         animations.append(animation)

# # 字符表排序动画名称
# animations.sort(key=lambda x: x["name"])
# save_animations(animations, "wilsondragonfly", "wilsondragonfly.json")

print(f"Time taken: {time() - start:.2f} seconds")
