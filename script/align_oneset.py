import os
import numpy as np
import scipy.io as sio

# 参数

input_root = r''
output_root = r''

window_size = 20
threshold_ratio = 0.3
align_point = 20
target_length = 1000


# RMS计算

def compute_rms(signal, window):

    rms = []

    for i in range(len(signal) - window):
        segment = signal[i:i + window]
        rms_value = np.sqrt(np.mean(segment ** 2))
        rms.append(rms_value)

    return np.array(rms)


# Onset检测

def detect_onset(emg):

    rms_channels = []

    for ch in range(emg.shape[1]):
        rms = compute_rms(emg[:, ch], window_size)
        rms_channels.append(rms)

    rms_channels = np.array(rms_channels)

    rms_mean = np.mean(rms_channels, axis=0)

    threshold = threshold_ratio * np.max(rms_mean)

    onset = np.argmax(rms_mean > threshold)

    return onset

# 对齐函数

def align_signal(emg, onset):

    start = onset - align_point

    if start < 0:
        start = 0

    end = start + target_length

    if end > emg.shape[0]:
        end = emg.shape[0]

    aligned = emg[start:end]

    return aligned


# 处理单个mat文件

def process_mat_file(input_path, output_path):

    data = sio.loadmat(input_path)

    emg = data['emg']
    label = data['label']

    onset = detect_onset(emg)

    aligned_emg = align_signal(emg, onset)

    aligned_label = label[:aligned_emg.shape[0]]

    sio.savemat(output_path, {
        'emg': aligned_emg,
        'label': aligned_label,
        'onset': onset
    })

    print(os.path.basename(input_path),
          "onset =", onset,
          "length =", aligned_emg.shape[0])


# 主程序（递归处理datasets）

for root, dirs, files in os.walk(input_root):

    for file in files:

        if not file.endswith(".mat"):
            continue

        input_path = os.path.join(root, file)

        # 构造输出路径
        relative_path = os.path.relpath(root, input_root)
        output_dir = os.path.join(output_root, relative_path)

        os.makedirs(output_dir, exist_ok=True)

        output_path = os.path.join(output_dir, file)

        process_mat_file(input_path, output_path)

print("\n全部数据对齐完成！")