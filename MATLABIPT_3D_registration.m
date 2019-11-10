% MATLAB�ł�4�����C���[�W����C�ɓǂݍ��߂Ȃ��̂ŁAz�X�^�b�N��1���ǂݍ���(���킹�錩�{�ɂ���摜�ƈړ�������摜�̂Q��)
% GPU���g�p���Ă���

%% tif�t�@�C���̓ǂݎ��(target�̂�Stack)
tic
[file, file_path] = uigetfile('*.tif');
file_info = imfinfo([file_path, file]);
d1 = file_info(1).Height;
d2 = file_info(1).Width;
T = numel(file_info);
bit = file_info(1).BitDepth;
   
raw_IMG = zeros(d1,d2,T);
for t = 1:T
    raw_IMG(:,:,t) = imread([file_path, file], t);
end
disp('�f�[�^�ǂݎ�芮��')
toc

%Target = raw_IMG;
Target = gpuArray(raw_IMG);
%% tif�t�@�C���̓ǂݎ��(suorce�̂�Stack)
tic
[file, file_path] = uigetfile('*.tif');
file_info = imfinfo([file_path, file]);
d1 = file_info(1).Height;
d2 = file_info(1).Width;
T = numel(file_info);
bit = file_info(1).BitDepth;
   
raw_IMG = zeros(d1,d2,T);
for t = 1:T
    raw_IMG(:,:,t) = imread([file_path, file], t);
end
disp('�f�[�^�ǂݎ�芮��')
toc

%Source = raw_IMG;
Source = gpuArray(raw_IMG);
%% ���W�X�g
tic
%[optimizer, metric] = imregconfig('monomodal');
%[optimizer, metric] = imregconfig('multimodal');
% optimizer.InitialRadius = 0.009;
% optimizer.Epsilon = 1.5e-4;
% optimizer.GrowthFactor = 1.01;
% optimizer.MaximumIterations = 300;
%[moving_reg, R_reg] = imregister(Source, Target,'rigid',optimizer,metric);

[D,moving_reg] = imregdemons(Source, Target);
moving_reg = gather(moving_reg);
disp('���W�X�g����')
toc

%% ��������
tic
IMG = cast(moving_reg,['uint',num2str(bit)]);
imwrite(IMG(:,:,1),[file_path, '3Dreged_', file,'.tif']);
for t = 2:T
    imwrite(IMG(:,:,t),[file_path, '3Dreged_', file,'.tif'],'WriteMode','append');
end
disp('�������݊���')
toc