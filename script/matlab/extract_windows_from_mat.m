function [emg_data_train, emg_label_train, emg_data_test, emg_label_test] = extract_windows_from_mat(filename, win_size, step, train_ratio)
%EXTRACT_WINDOWS_FROM_MAT Extract sliding-window EMG segments from one .mat file.
%
% Each .mat file should contain:
%   - emg:   EMG signal with shape [1000, 8]
%   - label: gesture label
%
% Output:
%   - emg_data_train:  [8, win_size, num_train_windows]
%   - emg_label_train: [num_train_windows, 1]
%   - emg_data_test:   [8, win_size, num_test_windows]
%   - emg_label_test:  [num_test_windows, 1]

    if nargin < 2
        win_size = 40;
    end

    if nargin < 3
        step = 5;
    end

    if nargin < 4
        train_ratio = 0.8;
    end

    data = load(filename);

    if ~isfield(data, 'emg')
        error('The file %s does not contain variable "emg".', filename);
    end

    if ~isfield(data, 'label')
        error('The file %s does not contain variable "label".', filename);
    end

    emg = data.emg;
    label = data.label;

    % Convert label to scalar
    label = int32(label(1));

    % The expected shape is [1000, 8].
    % If the data is accidentally stored as [8, 1000], transpose it.
    if size(emg, 1) == 8 && size(emg, 2) ~= 8
        emg = emg';
    end

    % Use the first 8 channels
    emg = abs(double(emg(:, 1:8)));

    num_points = size(emg, 1);
    num_channels = size(emg, 2);

    if num_channels ~= 8
        error('The EMG signal should have 8 channels. Current shape: [%d, %d].', size(emg, 1), size(emg, 2));
    end

    if num_points < win_size
        error('The signal length is shorter than the window size.');
    end

    num_samples = floor((num_points - win_size) / step) + 1;

    % Output shape: [channels, window_size, num_windows]
    emg_data = zeros(8, win_size, num_samples);

    for i = 1:num_samples
        idx_start = (i - 1) * step + 1;
        idx_end = idx_start + win_size - 1;

        segment = emg(idx_start:idx_end, 1:8);   % [win_size, 8]
        emg_data(:, :, i) = segment';            % [8, win_size]
    end

    % Split windows into train and test
    num_train = floor(train_ratio * num_samples);

    emg_data_train = emg_data(:, :, 1:num_train);
    emg_data_test = emg_data(:, :, num_train + 1:end);

    emg_label_train = repmat(label, size(emg_data_train, 3), 1);
    emg_label_test = repmat(label, size(emg_data_test, 3), 1);
end