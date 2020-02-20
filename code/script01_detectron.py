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
output_path_base = "../data/regions/"
instance_path_base = "../data/instances/"
input_paths = [x for x in os.listdir(input_path_base) if os.path.splitext(x)[1] == ".jpg"]
output_paths = [os.path.splitext(x)[0] + ".txt" for x in input_paths]

for ipath, opath in zip(input_paths, output_paths):

    if not os.path.exists(instance_path_base + opath):

        img = read_image(input_path_base + ipath, format="BGR")

        demo = VisualizationDemo(cfg)
        predictions, visualized_output = demo.run_on_image(img, img * 0)

        lookup = ["unknown"]
        for item in predictions['panoptic_seg'][1]:
            if item['isthing']:
                cat_next = thing[item['category_id']]
            else:
                cat_next = stuff[item['category_id']]
            lookup.append(cat_next)

        lookup = np.array(lookup)
        ps = predictions['panoptic_seg'][0].numpy()
        np.savetxt(output_path_base + opath, lookup[ps], delimiter=",", fmt="%s")

        instances = predictions['instances'].get_fields()

        pred_classes = []
        scores = []
        sizes = []

        for iter in range(len(instances['scores'])):
            pred_classes += [thing[int(instances['pred_classes'][iter])]]
            scores += [float(instances['scores'][iter])]
            sizes += [int(instances['pred_boxes'][iter].area())]

        pd.DataFrame(
            dict(pred_classes = pred_classes, scores = scores, sizes = sizes)
        ).to_csv(instance_path_base + opath, header=False, index=False)
