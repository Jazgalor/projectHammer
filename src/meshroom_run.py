import os
import subprocess

image_folder = "./output/buddha_mini6_blacked"

output_folder = "./output/meshroom"

graph_folder = "./src/draft_2048.mg"

cache_folder = os.path.abspath("./MeshroomCache")

subprocess.run(["meshroom_batch", "--input", image_folder, "--output", output_folder, "--pipeline", graph_folder, "--cache", cache_folder])