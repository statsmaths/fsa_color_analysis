
To run the caption analysis, download the repository and copy my script:

```
git clone https://github.com/sgrvinod/a-PyTorch-Tutorial-to-Image-Captioning
cp taylor_caption_moveme.py a-PyTorch-Tutorial-to-Image-Captioning/taylor_caption.py
cd a-PyTorch-Tutorial-to-Image-Captioning
```

Then, download the two files here:

- https://drive.google.com/drive/folders/189VY65I_n4RTpQnmLGj7IzVnOF6dmePC

That should give you these two files, which need to be in the root of the
cloned repository:

- BEST_checkpoint_coco_5_cap_per_img_5_min_word_freq.pth.tar
- WORDMAP_coco_5_cap_per_img_5_min_word_freq.json

Next, copy the directory of images into the git repository and run the following
script:

```{r}
python taylor_caption.py --img='1a35198v.jpg' \
   --model='BEST_checkpoint_coco_5_cap_per_img_5_min_word_freq.pth.tar' \
   --word_map='WORDMAP_coco_5_cap_per_img_5_min_word_freq.json' --beam_size=5

cp captions.txt ../../data   # copy the file into our data directory
```

And that's it. It seemed to take about an hour to do the whole thing, which is
not really too bad. The file `taylor_caption.py` has a small R script at the
bottom that creates an index file to look at the captions easily.
