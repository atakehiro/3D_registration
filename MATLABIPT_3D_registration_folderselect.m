% MATLAB�ł�4�����C���[�W����C�ɓǂݍ��߂Ȃ��̂ŁAz�X�^�b�N��1���ǂݍ���
% GPU���g�p���Ă���
% ���̓t�H���_�Əo�̓t�H���_��I������
% �t�H���_��I�����āA�ŏ��̃t�@�C�����^�[�Q�b�g�Ƃ���

%% �t�H���_�I��
inputdir = uigetdir;
S = dir(inputdir);
outputdir = uigetdir;
output_path = [outputdir , '/'];
%% tif�t�@�C���̓ǂݎ��(target�̂�Stack)
tic
path = [inputdir, '/', S(3).name];
file_info = imfinfo(path);
d1 = file_info(1).Height;
d2 = file_info(1).Width;
T = numel(file_info);
bit = file_info(1).BitDepth;
raw_IMG = zeros(d1,d2,T);
for t = 1:T
    raw_IMG(:,:,t) = imread(path, t);
end
disp('�f�[�^�ǂݎ�芮��')
toc
Target = gpuArray(raw_IMG);

%% 1�t���[���ڏ�������
tic
IMG = cast(raw_IMG,['uint',num2str(bit)]);
imwrite(IMG(:,:,1),[output_path, '3Dreged_',  S(3).name,'.tif']);
for t = 2:T
    imwrite(IMG(:,:,t),[output_path, '3Dreged_', S(3).name,'.tif'],'WriteMode','append');
end
disp('�������݊���')
toc
%% �t�H���_���̑S����
for i = 4:size(S,1)
    %% tif�t�@�C���̓ǂݎ��(suorce�̂�Stack)
    tic
    path = [inputdir, '/', S(i).name];
    file_info = imfinfo(path);
    d1 = file_info(1).Height;
    d2 = file_info(1).Width;
    T = numel(file_info);
    bit = file_info(1).BitDepth;
    raw_IMG = zeros(d1,d2,T);
    for t = 1:T
        raw_IMG(:,:,t) = imread(path, t);
    end
    disp('�f�[�^�ǂݎ�芮��')
    toc
    Source = gpuArray(raw_IMG);
    
    %% ���W�X�g
    tic
    [D,moving_reg] = imregdemons(Source, Target);
    moving_reg = gather(moving_reg);
    disp('���W�X�g����')
    toc

    %% ��������
    tic
    IMG = cast(moving_reg,['uint',num2str(bit)]);
    imwrite(IMG(:,:,1),[output_path, '3Dreged_',  S(i).name,'.tif']);
    for t = 2:T
        imwrite(IMG(:,:,t),[output_path, '3Dreged_', S(i).name,'.tif'],'WriteMode','append');
    end
    disp('�������݊���')
    toc
    
end