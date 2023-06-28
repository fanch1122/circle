#!/bin/bash
#version 1.2
#从ena的tsv中提取链接，然后用ascp进行下载
if [ "$#" -ne 1 ]; then
  echo "Usage: bash script.sh <input_file>"
  exit 1
fi

input_file="$1"
output_file="links.txt"
save_dir="$PWD/../data"
private_key="/home/zhongshan/.aspera/connect/etc/asperaweb_id_dsa.openssh"

# Extract the column with the header "fastq_ftp" from the tsv file
awk -F'\t' 'NR == 1 { for (i=1; i<=NF; i++) { if ($i == "fastq_ftp") { col_idx=i; break; } } } NR > 1 { print $col_idx }' "$input_file" > "$output_file"

echo "Extraction complete. The links are saved in $output_file."

while IFS=';' read -ra ftp_urls; do
  for ftp_url in "${ftp_urls[@]}"; do
    if [[ "$ftp_url" =~ ftp.sra.ebi.ac.uk.*fastq.gz ]]; then
      file_path="${ftp_url#ftp.sra.ebi.ac.uk/}"
      file_name="${file_path##*/}"
      echo "Downloading ...${file_name}..."
      ascp -v -k 1 -P33001 -QT -l 300m -i "${private_key}" "era-fasp@fasp.sra.ebi.ac.uk:${file_path}" "${save_dir}"
      echo "Download of ===${file_name}=== completed.\\t"
    fi
  done
done < "$output_file"
