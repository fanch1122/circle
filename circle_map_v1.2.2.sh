#!/bin/bash
# 2023.06.25
# version=1.2.2

# 激活 conda 环境
source ~/miniconda3/etc/profile.d/conda.sh
conda activate circle_map

# 设置工作目录和参考序列目录
one_of_multi=$PWD
ref_dir="$PWD/ref"

for sample_fna in "$ref_dir"/*.fna; do
    # 提取样本名
    sample_name=$(basename "$sample_fna" .fna)

    # 构建参考序列文件路径
    reference="$ref_dir/$sample_name.fa"

    # 创建输出文件夹
    output_dir="$one_of_multi/aligned_data"
    mkdir -p "$output_dir"

    # 复制参考序列文件并创建索引
    cp "$sample_fna" "$reference"
    bwa index "$reference"

    echo "Reference: $reference"

    # 处理双端测序样本
    for input_file_1 in "$one_of_multi"/trimdata/*_1.fq.gz; do
        # 提取样本名
        sample_name=$(basename "$input_file_1" _1_val_1.fq.gz)

        # 构建输入文件路径
        input_file_2="$one_of_multi/trimdata/${sample_name}_2_val_2.fq.gz"
        echo "$input_file_2"
    
        # 构建输出文件名前缀
        output_prefix="$output_dir/$sample_name"

        # 解压样本文件
        gunzip -c "$input_file_1" > "${output_prefix}_1.fq"
        gunzip -c "$input_file_2" > "${output_prefix}_2.fq"

        echo "Unzipped sample: $sample_name"

        # 执行比对和分析
        bwa mem "$reference" "${output_prefix}_1.fq" "${output_prefix}_2.fq" | samtools sort -o "${output_prefix}_sorted.bam"
        samtools index "${output_prefix}_sorted.bam"
        #Circle-Map Repeats -i "${output_prefix}_sorted.bam" -o "${output_prefix}_circle.bed"

        echo "Processed sample: $sample_name"
    done

    echo "Processed reference: $sample_name"
done

echo "All samples processed."

Circle-Map Repeats -i "${output_prefix}_sorted.bam" -o "${output_prefix}_circle.bed"
