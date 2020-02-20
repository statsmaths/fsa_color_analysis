from detectron2.config import get_cfg
from detectron2.data.detection_utils import read_image
from detectron2.utils.logger import setup_logger
from detectron2.data import MetadataCatalog
from detectron2.utils.visualizer import ColorMode, Visualizer

from predictor import VisualizationDemo
import numpy as np
import torch
import os
import pandas as pd

cfg = get_cfg()
cfg.merge_from_file("configs/COCO-PanopticSegmentation/panoptic_fpn_R_101_3x.yaml")
cfg.merge_from_list(['MODEL.DEVICE', 'cpu', 'MODEL.WEIGHTS', 'models/model_final_cafdb1.pkl'])
cfg.MODEL.RETINANET.SCORE_THRESH_TEST = 0.5
cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.5
cfg.MODEL.PANOPTIC_FPN.COMBINE.INSTANCES_CONFIDENCE_THRESH = 0.5
cfg.freeze()

stuff = MetadataCatalog.get(cfg.DATASETS.TEST[0]).stuff_classes
thing = MetadataCatalog.get(cfg.DATASETS.TEST[0]).thing_classes

input_path_base = "../data/images/"
output_img_path_base = "../data/annotations/"

input_paths = ["1a33896v.jpg", "1a34052v.jpg", "1a34564v.jpg", "1a35003v.jpg"]
output_paths = [os.path.splitext(x)[0] + ".jpg" for x in input_paths]

for ipath, opath in zip(input_paths, output_paths):

    if not os.path.exists(output_img_path_base + opath):

        img = read_image(input_path_base + ipath, format="BGR")
        img2 = img * 0 + 255

        demo = VisualizationDemo(cfg)
        predictions, visualized_output = demo.run_on_image(img, img2)

        visualized_output.save(output_img_path_base + opath)
