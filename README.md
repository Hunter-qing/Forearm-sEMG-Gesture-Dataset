# Forearm sEMG Gesture Dataset

## Overview

This repository provides a forearm surface electromyography (sEMG) dataset for hand gesture recognition.

The dataset contains EMG signals collected from 30 subjects performing five hand gestures and one rest state. Each trial lasts 5 seconds.

## Dataset Information

- Signal type: Surface electromyography (sEMG)
- Recording position: Forearm muscles
- Number of subjects: 30
- Number of sessions per subject: 5
- Number of channels: 8
- Sampling rate: 200 Hz
- Duration of each trial: 5 seconds
- Sampling points per channel: 1000
- File format: MATLAB `.mat`

Each `.mat` file records a complete gesture trial lasting 5 seconds. During each trial, the subject first stays relaxed, then starts to perform the gesture after receiving the gesture prompt, and finally maintains the gesture for the remaining duration. Therefore, each trial may contain three stages:

1. rest state before movement,
2. transition from rest to gesture,
3. sustained gesture state.

Each `.mat` file contains two variables:

| Variable | Description |
|---|---|
| `emg` | 8-channel EMG signal |
| `label` | Gesture label |

The shape of `emg` is:

```text
1000 × 8
```

where 1000 is the number of sampling points and 8 is the number of channels.

## Gesture Labels

| Label | Gesture | Chinese |
|---|---|---|
| 0 | Rest | 放松 |
| 1 | Fist | 握拳 |
| 2 | Open Palm | 伸掌 |
| 3 | Left Wrist Deviation | 左撇 |
| 4 | Right Wrist Deviation | 右撇 |
| 5 | Thumbs Up | 竖大拇指 |

## Dataset Structure

```text
datasets/
├── subject_001/
│   ├── session_01/
│   │   ├── gesture_1_01.mat
│   │   ├── gesture_1_02.mat
│   │   ├── gesture_2_01.mat
│   │   ├── gesture_3_01.mat
│   │   ├── gesture_4_01.mat
│   │   ├── gesture_5_01.mat
│   │   ├── rest_01.mat
│   │   └── ...
│   ├── session_02/
│   └── ...
├── subject_002/
└── ...
```

## File Naming

Gesture files:

```text
gesture_[label]_[trial_index].mat
```

Example:

```text
gesture_1_01.mat
```

means the first trial of gesture 1, which is `Fist`.

Rest files:

```text
rest_[trial_index].mat
```

Example:

```text
rest_01.mat
```

means the first rest-state trial.

## Gesture Onset Alignment

This repository also provides a simple onset-alignment script: Considering that each subject had a different reaction time, all .mat files were data-aligned: 20 sample points (you can modify) were uniformly retained before the significant change in the EMG signal, and any excess points were truncated.

```text
scripts/align_onset.py
```

## MATLAB Preprocessing Scripts

This repository provides MATLAB scripts for converting the original `.mat` files into H5 files with sliding-window method.

The scripts are located in:

```text
scripts/matlab/
├── extract_windows_from_mat.m
└── batch_convert_to_h5.m
```

## Suggested Usage

This dataset can be used for:

- EMG-based gesture recognition
- Hand gesture classification
- Human-computer interaction research
- Signal processing and machine learning experiments

## Privacy

All subject identities have been anonymized. The dataset does not contain names, student IDs, phone numbers, emails, or other directly identifiable personal information.

Users must not attempt to re-identify any subject.

## License

This dataset is released under the Creative Commons Attribution 4.0 International License (CC BY 4.0).

The MATLAB preprocessing scripts are released under the MIT License.

Please cite this repository if you use the dataset.

## Citation

If you use this dataset in your research, project, or publication, please cite it as follows:

```bibtex
@misc{forearm_semg_gesture_dataset_2026,
  title        = {Forearm sEMG Gesture Dataset for Hand Gesture Recognition},
  author       = {Hu, Yongcheng and Hu, Shuai},
  year         = {2026},
  version      = {1.0.0},
  publisher    = {GitHub},
  howpublished = {\url{https://github.com/Hunter-qing/Forearm-sEMG-Gesture-Dataset}},
  note         = {A forearm surface electromyography dataset containing 30 subjects, 5 gestures, and rest-state trials}
}
