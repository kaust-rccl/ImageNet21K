# --------------------------------------------------------
# ImageNet-21K Pretraining for The Masses
# Copyright 2021 Alibaba MIIL (c)
# Licensed under MIT License [see the LICENSE file for details]
# Written by Tal Ridnik
# Edited by Dr. David R. Pugh (KAUST)
# --------------------------------------------------------

PROJECT_DIR=/ibex/ai/reference/CV/ingest
DATA_DIR=$PROJECT_DIR/data/raw
TRAIN_DIR=$DATA_DIR/train # target folder, adjust this path

# untarring the original tar to 21k tar's:
tar -xvzf $DATA_DIR/winter21_whole.tar.gz -C $DATA_DIR
mv $DATA_DIR/winter21_whole $TRAIN_DIR

find $TRAIN_DIR -type f -print | wc -l # 19167

# extracting all tar's in parallel (!)
cd $TRAIN_DIR
find . -name "*.tar" | parallel 'echo {};  ext={/}; target_folder=${ext%.*}; mkdir -p $target_folder;  tar  -xf {} -C $target_folder'

# counting the nubmer of classes
find ./ -mindepth 1 -type d | wc -l # 19167

# delete all tar's
rm *.tar

# Remove uncommon classes for transfer learning
SMALL_CLASSES_DIR=$DATA_DIR/small-classes
mkdir -p ${SMALL_CLASSES_DIR}
for c in ${TRAIN_DIR}/n*; do
    count=`ls $c/*.JPEG | wc -l`
    if [ "$count" -gt "500" ]; then
        echo "keep $c, count = $count"
    else
        echo "remove $c, $count"
        mv $c ${SMALL_CLASSES_DIR}/
    fi
done

# counting the number of valid classes
find ./ -mindepth 1 -type d | wc -l  # 10450

# create validation set, 50 images in each folder
VAL_DIR=${DATA_DIR}/val
mkdir -p ${VAL_DIR}
for i in ${TRAIN_DIR}/n*; do
    c=`basename $i`
    echo $c
    mkdir -p ${VAL_DIR}/$c
#    for j in `ls $i/*.JPEG | shuf | head -n 50`; do
    for j in `ls $i/*.JPEG | head -n 50`; do # no shuf for reproducibility
        mv $j ${VAL_DIR}/$c/
    done
done
