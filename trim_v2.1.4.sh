#!/bin/bash
# author: fanch
# version: 2.1.4
#修正环境问题
cd $PWD/../

source ~/miniconda3/etc/profile.d/conda.sh
conda activate circle_map
# 设置 eccDNA 目录
one_of_multi="$PWD"
# 切换到 eccDNA 目录
cd "$one_of_multi"
mkdir -p "$one_of_multi/trimdata"

# 输入文件夹路径
input_dir="${one_of_multi}/data"
# 输出文件夹路径
output_dir="${one_of_multi}/trimdata"

# 处理双端测序样本
for input_file_1 in "$input_dir"/*_1.fastq.gz; do
  # 提取样本名
  sample_name=$(basename "$input_file_1" _1.fastq.gz)

  # 构建输入文件路径
  input_file_2="$input_dir/${sample_name}_2.fastq.gz"

  # 构建输出文件夹路径
  sample_output_dir="$output_dir"

  # 创建输出文件夹
  mkdir -p "$sample_output_dir"

  # 运行 trim_galore 命令
  trim_galore -q 20 -e 0.1 -O "$sample_output_dir" --paired "$input_file_1" "$input_file_2"

  # 输出运行信息
  echo "Processed sample: $sample_name"
done

conda deactivate
