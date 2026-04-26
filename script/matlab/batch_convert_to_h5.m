clear;
clc;

% =========================
% Parameters
% =========================

root_dir = 'C:\Users\Lenovo\Desktop\新建文件夹\dataset';        % Dataset root folder
output_dir = 'C:\Users\Lenovo\Desktop\新建文件夹\h5_windows';    % Output folder for H5 files

win_size = 40;      % 40 samples = 200 ms at 200 Hz
step = 5;           % 5 samples = 25 ms at 200 Hz
train_ratio = 0.8;  % First 80% windows for training, last 20% for testing

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% The dataset folders are expected to be subject_001, subject_002, ...
subjects = dir(fullfile(root_dir, 'subject_*'));
subjects = subjects([subjects.isdir]);

gesture_names = {
    'rest', ...
    'gesture1', ...
    'gesture2', ...
    'gesture3', ...
    'gesture4', ...
    'gesture5'
};

% =========================
% Process each subject
% =========================

for u = 1:length(subjects)

    subject_name = subjects(u).name;
    subject_path = fullfile(root_dir, subject_name);

    sessions = dir(fullfile(subject_path, 'session*'));
    sessions = sessions([sessions.isdir]);

    % Containers for 6 classes:
    % label 0: rest
    % label 1: fist
    % label 2: open palm
    % label 3: left deviation
    % label 4: right deviation
    % label 5: thumbs up
    gesture_data_train = cell(6, 1);
    gesture_label_train = cell(6, 1);
    gesture_data_test = cell(6, 1);
    gesture_label_test = cell(6, 1);

    for g = 1:6
        gesture_data_train{g} = [];
        gesture_label_train{g} = [];
        gesture_data_test{g} = [];
        gesture_label_test{g} = [];
    end

    fprintf('\nProcessing %s...\n', subject_name);

    % =========================
    % Traverse sessions
    % =========================

    for s = 1:length(sessions)

        session_path = fullfile(subject_path, sessions(s).name);
        mat_files = dir(fullfile(session_path, '*.mat'));

        for m = 1:length(mat_files)

            mat_file = fullfile(session_path, mat_files(m).name);

            [train_data, train_label, test_data, test_label] = extract_windows_from_mat( ...
                mat_file, win_size, step, train_ratio);

            if isempty(train_label)
                continue;
            end

            label_value = double(train_label(1));

            if label_value < 0 || label_value > 5
                warning('Skip file with invalid label: %s', mat_file);
                continue;
            end

            gid = label_value + 1;

            gesture_data_train{gid} = cat(3, gesture_data_train{gid}, train_data);
            gesture_label_train{gid} = cat(1, gesture_label_train{gid}, train_label);

            gesture_data_test{gid} = cat(3, gesture_data_test{gid}, test_data);
            gesture_label_test{gid} = cat(1, gesture_label_test{gid}, test_label);

        end
    end

    % =========================
    % Save H5 files
    % =========================

    for g = 1:6

        train_data = gesture_data_train{g};
        train_label = int32(gesture_label_train{g});

        test_data = gesture_data_test{g};
        test_label = int32(gesture_label_test{g});

        if isempty(train_data)
            continue;
        end

        gesture_name = gesture_names{g};

        train_file = fullfile(output_dir, sprintf('%s_%s_train.h5', subject_name, gesture_name));
        test_file = fullfile(output_dir, sprintf('%s_%s_test.h5', subject_name, gesture_name));

        % Delete existing files to avoid h5create errors
        if exist(train_file, 'file')
            delete(train_file);
        end

        if exist(test_file, 'file')
            delete(test_file);
        end

        % Save train file
        h5create(train_file, '/image_new_Data', size(train_data), 'Datatype', 'double');
        h5create(train_file, '/image_new_Label', size(train_label), 'Datatype', 'int32');

        h5write(train_file, '/image_new_Data', train_data);
        h5write(train_file, '/image_new_Label', train_label);

        % Save test file
        h5create(test_file, '/image_new_Data', size(test_data), 'Datatype', 'double');
        h5create(test_file, '/image_new_Label', size(test_label), 'Datatype', 'int32');

        h5write(test_file, '/image_new_Data', test_data);
        h5write(test_file, '/image_new_Label', test_label);

        fprintf('Saved: %s\n', train_file);
        fprintf('Saved: %s\n', test_file);

    end
end

fprintf('\nAll files have been converted to H5 format.\n');