% MATLABでは4次元イメージを一気に読み込めないので、zスタックを1つずつ読み込む(合わせる見本にする画像と移動させる画像の２つ)
% GPUを使用している

%% tifファイルの読み取り（targetのｚStack）
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
disp('データ読み取り完了')
toc

%Target = raw_IMG;
Target = gpuArray(raw_IMG);
%% tifファイルの読み取り（suorceのｚStack）
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
disp('データ読み取り完了')
toc

%Source = raw_IMG;
Source = gpuArray(raw_IMG);
%% レジスト
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
disp('レジスト完了')
toc

%% 書き込み
tic
IMG = cast(moving_reg,['uint',num2str(bit)]);
imwrite(IMG(:,:,1),[file_path, '3Dreged_', file]);
for t = 2:T
    imwrite(IMG(:,:,t),[file_path, '3Dreged_', file],'WriteMode','append');
end
disp('書き込み完了')
toc
